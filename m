From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [E1000-devel] [linux-nics] Problem: 82574L device (e1000e driver):
 Reset adapter unexpectedly / transmit queue 0 timed out
Date: Tue, 22 Jul 2014 08:25:13 -0700
Message-ID: <53CE8259.6080400@intel.com>
References: <CAJtEV7bERYgwtQv1zAvk+XzaywF6g7K-QqAq3VLErNU1YSgxYA@mail.gmail.com>	<9B4A1B1917080E46B64F07F2989DADD6533A4E9C@ORSMSX114.amr.corp.intel.com>	<CAJtEV7aCm9AWW3vNQO1pjxorYnGAQQG0MRnPHwy7COx7eM8eFg@mail.gmail.com> <CAJtEV7Z=54cHbZ8SiYmgm7=osncs1SaQG=adhht-3NmWrkG1ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dmitry Lifshitz <lifshitz@compulab.co.il>,
	netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	Igor Grinberg <grinberg@compulab.co.il>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>
To: Andrew Cooks <acooks@gmail.com>,
	"Fujinaka, Todd" <todd.fujinaka@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63050 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751391AbaGVPZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 11:25:30 -0400
In-Reply-To: <CAJtEV7Z=54cHbZ8SiYmgm7=osncs1SaQG=adhht-3NmWrkG1ww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>> # lspci -vvnnk:
>>>> 01:00.0 Ethernet controller [0200]: Intel Corporation 82574L Gigabit Network Connection [8086:10d3]
>>>>         Subsystem: Intel Corporation Device [8086:0000]
>>>>         Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>>>>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>>>>         Interrupt: pin A routed to IRQ 16
>>>>         Region 0: [virtual] Memory at c1900000 (32-bit, non-prefetchable) [size=128K]
>>>>         Region 1: [virtual] Memory at c1800000 (32-bit, non-prefetchable) [size=1M]
>>>>         Region 2: I/O ports at 7000 [size=32]
>>>>         Region 3: [virtual] Memory at c1920000 (32-bit, non-prefetchable) [size=16K]
>>>>         [virtual] Expansion ROM at c1940000 [disabled] [size=256K]
>>>>         Capabilities: [c8] Power Management version 2
>>>>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>>>>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
>>>>         Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
>>>>                 Address: 0000000000000000  Data: 0000
>>>>         Capabilities: [e0] Express (v1) Endpoint, MSI 00
>>>>                 DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
>>>>                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
>>>>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
>>>>                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>>>                         MaxPayload 128 bytes, MaxReadReq 512 bytes
>>>>                 DevSta: CorrErr+ UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
>>>>                 LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <64us
>>>>                         ClockPM- Surprise- LLActRep- BwNot-
>>>>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
>>>>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>>>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
>>>>         Capabilities: [a0] MSI-X: Enable- Count=5 Masked-
>>>>                 Vector table: BAR=3 offset=00000000
>>>>                 PBA: BAR=3 offset=00002000
>>>>         Capabilities: [100 v1] Advanced Error Reporting
>>>>                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
>>>>                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>>>>                 UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
>>>>                 CESta:  RxErr+ BadTLP+ BadDLLP+ Rollover- Timeout- NonFatalErr+
>>>>                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
>>>>                 AERCap: First Error Pointer: 14, GenCap- CGenEn- ChkCap- ChkEn-
>>>>         Capabilities: [140 v1] Device Serial Number 00-01-c0-ff-ff-12-8a-64
>>>>         Kernel driver in use: e1000e
>>>>
>>>>

It looks like something bad happened on the PCIe bus based on the RxErr,
BadTLP, BadDLLP, and NonFatalERR indicators all being set.  This could
be an indication of a possible problem with the PCIe link on the system.

>>>> # ethtool -d eth2
>>>> MAC Registers
>>>> -------------
>>>> 0x00000: CTRL (Device control register)  0xFFFFFFFF
>>>>       Endian mode (buffers):             big
>>>>       Link reset:                        reset
>>>>       Set link up:                       1
>>>>       Invert Loss-Of-Signal:             yes
>>>>       Receive flow control:              enabled
>>>>       Transmit flow control:             enabled
>>>>       VLAN mode:                         enabled
>>>>       Auto speed detect:                 enabled
>>>>       Speed select:                      not used
>>>>       Force speed:                       yes
>>>>       Force duplex:                      yes
>>>> 0x00008: STATUS (Device status register) 0xFFFFFFFF
>>>>       Duplex:                            full
>>>>       Link up:                           link config
>>>>       TBI mode:                          enabled
>>>>       Link speed:                        not used
>>>>       Bus type:                          PCI-X
>>>>       Bus speed:                         133MHz
>>>>       Bus width:                         64-bit
>>>> 0x00100: RCTL (Receive control register) 0xFFFFFFFF
>>>>       Receiver:                          enabled
>>>>       Store bad packets:                 enabled
>>>>       Unicast promiscuous:               enabled
>>>>       Multicast promiscuous:             enabled
>>>>       Long packet:                       enabled
>>>>       Descriptor minimum threshold size: reserved
>>>>       Broadcast accept mode:             accept
>>>>       VLAN filter:                       enabled
>>>>       Canonical form indicator:          enabled
>>>>       Discard pause frames:              ignored
>>>>       Pass MAC control frames:           pass
>>>>       Receive buffer size:               4096
>>>> 0x02808: RDLEN (Receive desc length)     0xFFFFFFFF
>>>> 0x02810: RDH   (Receive desc head)       0xFFFFFFFF
>>>> 0x02818: RDT   (Receive desc tail)       0xFFFFFFFF
>>>> 0x02820: RDTR  (Receive delay timer)     0xFFFFFFFF
>>>> 0x00400: TCTL (Transmit ctrl register)   0xFFFFFFFF
>>>>       Transmitter:                       enabled
>>>>       Pad short packets:                 enabled
>>>>       Software XOFF Transmission:        enabled
>>>>       Re-transmit on late collision:     enabled
>>>> 0x03808: TDLEN (Transmit desc length)    0xFFFFFFFF
>>>> 0x03810: TDH   (Transmit desc head)      0xFFFFFFFF
>>>> 0x03818: TDT   (Transmit desc tail)      0xFFFFFFFF
>>>> 0x03820: TIDV  (Transmit delay timer)    0xFFFFFFFF
>>>> PHY type:                                unknown
>>>>
>>>>

The device doesn't appear to be responding to MMIO reads based on the
fact that all of the registers are returning all 1's.

You should be able to recover from this error by issuing a PCIe device
reset request via the sysfs interface (echo 1 >
/sys/bus/pci/devices/0000\:01\:00.0/reset).  However that only resolves
the issue after it has occurred.

One thing that would probably be useful would be to provide an "lspci
-vvv" for the entire system.  That would at least give us an idea of the
PCIe hierarchy and could help to tell us if the problem is something in
the local PCIe hierarchy for the device, or if the problem is closer to
the root complex.

Thanks,

Alex
