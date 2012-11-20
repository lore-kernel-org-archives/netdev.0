From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: 82571EB: Detected Hardware Unit Hang
Date: Tue, 20 Nov 2012 08:59:00 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA8913349EB41@ORSMSX102.amr.corp.intel.com>
References: <509B5038.8090304@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA89133487884@ORSMSX102.amr.corp.intel.com>
 <50A30656.6090508@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA8913348B105@ORSMSX102.amr.corp.intel.com>
 <50A43828.6000702@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA8913349A0B4@ORSMSX102.amr.corp.intel.com>
 <50A9C5CC.1030300@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mary Mcgrath <mary.mcgrath@oracle.com>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50A9C5CC.1030300@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Joe Jin [mailto:joe.jin@oracle.com]
>Sent: Sunday, November 18, 2012 9:38 PM
>To: Dave, Tushar N
>Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org; Mary Mcgrath
>Subject: Re: 82571EB: Detected Hardware Unit Hang
>
>On 11/16/12 04:26, Dave, Tushar N wrote:
>>> Would you please help to fine the offset of max payload size in eeprom?
>>> I'd like to have a try to modify it by ethtool.
>>
>> It is defined using bit 8 of word 0x1A.
>> Bit value 0 = 128B , bit value 1 = 256B
>
>Hi Tushar,
>
>I checked one of my server which Max Payload Size is 128:
>
># lspci -vvv -s 52:00.1
>52:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
>Controller (rev 06)
>        Subsystem: Intel Corporation PRO/1000 PT Quad Port Server Adapter
>        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>ParErr+ Stepping- SERR- FastB2B- DisINTx+
>        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
><TAbort- <MAbort- >SERR- <PERR- INTx-
>        Latency: 0, Cache Line Size: 64 bytes
>        Interrupt: pin B routed to IRQ 266
>        Region 0: Memory at dfea0000 (32-bit, non-prefetchable)
>[size=128K]
>        Region 1: Memory at dfe80000 (32-bit, non-prefetchable)
>[size=128K]
>        Region 2: I/O ports at 6020 [size=32]
>        [virtual] Expansion ROM at d8120000 [disabled] [size=128K]
>        Capabilities: [c8] Power Management version 2
>                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-
>,D3hot+,D3cold-)
>                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
>        Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
>                Address: 00000000fee00000  Data: 409a
>        Capabilities: [e0] Express (v1) Endpoint, MSI 00
>                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
><512ns, L1 <64us
>                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
>                DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+
>Unsupported+
>                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>                        MaxPayload 128 bytes, MaxReadReq 4096 bytes
>                DevSta: CorrErr- UncorrErr- FatalErr+ UnsuppReq+ AuxPwr-
>TransPend-
>                LnkCap: Port #0, Speed 2.5GT/s, Width x4, ASPM L0s,
>Latency L0 <4us, L1 <64us
>                        ClockPM- Surprise- LLActRep- BwNot-
>                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
>CommClk+
>                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+
>DLActive- BWMgmt- ABWMgmt-
>        Capabilities: [100 v1] Advanced Error Reporting
>                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
>RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
>                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
>RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
>                UESvrt: DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+
>RxOF+ MalfTLP+ ECRC- UnsupReq+ ACSViol-
>                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-
>NonFatalErr-
>                CEMsk:  RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+
>NonFatalErr-
>                AERCap: First Error Pointer: 14, GenCap- CGenEn- ChkCap-
>ChkEn-
>        Capabilities: [140 v1] Device Serial Number 00-15-17-ff-ff-16-ed-
>86
>        Kernel driver in use: e1000e
>        Kernel modules: e1000e
>
>And eeprom dump as below:
>
>Offset          Values
>------          ------
>0x0000          00 15 17 16 ed 86 24 05 ff ff a2 50 ff ff ff ff
>0x0010          57 d4 07 74 2f a4 a4 11 86 80 a4 10 86 80 65 b1
>0x0020          08 00 a4 10 00 58 00 00 01 50 00 00 00 00 00 01
>0x0030          f6 6c b0 37 a6 07 03 84 83 07 00 00 03 c3 02 06
>0x0040          08 00 f0 0e 64 21 40 00 01 40 00 00 00 00 00 00
>0x0050          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>0x0060          00 01 00 40 1e 12 07 40 00 01 00 40 ff ff ff ff
>
>
>If I did not misunderstand, the value of offset 0x1a is 0x07a6, then the
>bit 8 is 1, but my NIC's MPS is 128b, anything I'm wrong?

Have you power off the system completely after modifying eeprom? If not please do so.
-Tushar 
