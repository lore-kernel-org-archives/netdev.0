From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: Network Receive Problems on NetGearRn104 Armarda370
Date: Sat, 7 Mar 2015 14:56:30 +0100
Message-ID: <20150307145630.0c56619e@free-electrons.com>
References: <20150307145154.7afcd4a4@michael>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>
To: Michael Langer <michael.brainbug.langer@t-online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:43572 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752153AbbCGN4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 08:56:33 -0500
In-Reply-To: <20150307145154.7afcd4a4@michael>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Michael Langer,

On Sat, 7 Mar 2015 14:51:54 +0100, Michael Langer wrote:

> I have a Network problem on my Armarda370 based NetGear RN104. I use the RN104 as TV and NFS Server. The TV Service gets its data from a network attached receiver via ip6 multicast stream. In case of nfs traffic or video streams > 20MBit into the box the kernel log is filled with error messages [1]. While for the NFS Service only performance id affected. For the TV Service I get visible artifarcts due to missing packets.
> 
> The RN104 is connected to a managed switch (ProCurve 1810G-24) configured without jumbo frame support (MTU=1518). I could not trigger these messages by running 'iperf -s' on the server and 'iperf -c <ip-addr>' on the client side (~930MBit)?! The RN104 is a relplacement unit for a Kirwood based NAS which is still working. The old NAS is working without packet loss, so I think that I can rule out the network receiver as a source of the missing packets. 
> 
> Things I have checked with no success:
> - Ethernet hardware cable
> - change port on switch
> - chage port on RN104
> - Kernel 3.17.1.rn104 from natisbad.org did not report errors but gave also artifarcts on TV-Stream
> - Kernel Version 3.18,7, 3.19, 4.0-rc2
> - ethtool playing with coalesce rx-usecs/frames and rx ring buffer count
> - change nice level for TV-Service
> 
> At the moment I don't know how to proceed to solve the issue.

Thanks Michael for your detailed report. I'm adding Willy Tarreau in the
loop, who has done a lot of work on Armada 370 networking. He may have
some ideas of things to try to narrow down the problem.

Do you know if you could produce a test case that would allow us to
reproduce the problem?

I'm leaving the logs unchanged below so that Willy can have a look.

Thanks!

Thomas

> [1] kernel error messages:
> [  645.033693] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=272
> [  645.124548] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=440
> [  646.292391] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=504
> [  646.300810] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=264
> [  646.570845] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=896
> [  646.590264] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=816
> [  646.620702] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=640
> [  646.669245] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=1152
> [  647.064124] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=272
> [  647.547118] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=512
> [  647.910284] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=448
> [  647.951694] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=1408
> [  648.429839] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=448
> [  649.090540] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=1024
> [  649.116472] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=1408
> [  649.124982] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=384
> [  649.473988] mvneta d0070000.ethernet eth0: bad rx status 0f830000 (overrun error), size=512
> 
> The Kernel is compliled without external modules.
> # cat /proc/modules 
> -
> 
> # ls /sys/module/
> 8021q	     dm_bufio	   firmware_class  ipv6      md_mod		nfs	     raid456   smsc95xx     usbcore
> 8250	     dm_mirror	   fscache	   kernel    mvneta		nfsd	     rng_core  spurious     usbhid
> ahci	     dm_mod	   fuse		   keyboard  nbd		ntfs	     sata_mv   sunrpc	    vt
> asix	     dm_raid	   hid		   libahci   nf_conntrack	printk	     scsi_mod  tcp_cubic    workqueue
> auth_rpcgss  dm_snapshot   hid_apple	   libata    nf_conntrack_ftp	pxa3xx_nand  sg        ubi	    xhci_hcd
> block	     dns_resolver  ip6_tunnel	   lockd     nf_conntrack_ipv4	raid1	     sit       ubifs	    xz_dec
> configfs     ehci_hcd	   ipip		   loop      nf_conntrack_tftp	raid10	     smsc75xx  usb_storage
> 
> # cat /proc/version 
> Linux version 4.0.0-rc2.rn104 (michael@michael) (gcc version 4.9.2 (crosstool-NG 1.20.0) ) #6 Sat Mar 7 13:24:27 CET 2015
> 
> # cat /proc/ioports
> 00001000-000fffff : PCI I/O
>    00010000-00010fff : PCI Bus 0000:02
>      00010000-0001001f : 0000:02:00.0
>        00010000-0001001f : ahci
>      00010020-00010027 : 0000:02:00.0
>        00010020-00010027 : ahci
>      00010028-0001002f : 0000:02:00.0
>        00010028-0001002f : ahci
>      00010030-00010033 : 0000:02:00.0
>        00010030-00010033 : ahci
>      00010034-00010037 : 0000:02:00.0
>        00010034-00010037 : ahci
> 
> # cat /proc/iomem
> 00000000-1fffffff : System RAM
>    00008000-007e1563 : Kernel code
>    00816000-008b6647 : Kernel data
> d0011000-d001101f : /soc/internal-regs/i2c@11000
> d0012000-d001201f : serial
> d0018000-d0018037 : /soc/internal-regs/pin-ctrl@18000
> d0018100-d001813f : /soc/internal-regs/gpio@18100
> d0018140-d001817f : /soc/internal-regs/gpio@18140
> d0018180-d00181bf : /soc/internal-regs/gpio@18180
> d0018300-d0018303 : /soc/internal-regs/thermal@18300
> d0018304-d0018307 : /soc/internal-regs/thermal@18300
> d0020800-d0020807 : /soc/internal-regs/cpurst@20800
> d0020a00-d0020bcf : /soc/internal-regs/interrupt-controller@20000
> d0021870-d00218c7 : /soc/internal-regs/interrupt-controller@20000
> d0022000-d0022fff : /soc/internal-regs/pmsu@22000
> d0040000-d0041fff : /soc/pcie-controller/pcie@1,0
> d0050000-d00504ff : /soc/internal-regs/usb@50000
> d0070000-d0073fff : /soc/internal-regs/ethernet@70000
> d0074000-d0077fff : /soc/internal-regs/ethernet@74000
> d0080000-d0081fff : /soc/pcie-controller/pcie@2,0
> d00d0000-d00d0053 : /soc/internal-regs/nand@d0000
> f8000000-ffdfffff : PCI MEM
>    f8000000-f80fffff : PCI Bus 0000:01
>      f8000000-f800ffff : 0000:01:00.0
>        f8000000-f800ffff : xhci-hcd
>      f8010000-f8010fff : 0000:01:00.0
>      f8011000-f8011fff : 0000:01:00.0
>    f8100000-f81fffff : PCI Bus 0000:02
>      f8100000-f810ffff : 0000:02:00.0
>      f8110000-f81107ff : 0000:02:00.0
>        f8110000-f81107ff : ahci
> 
> # lspci -vvv
> 00:01.0 PCI bridge: Marvell Technology Group Ltd. Device 6710 (rev 01) (prog-if 00 [Normal decode])
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
> 	I/O behind bridge: 0000f000-00000fff
> 	Memory behind bridge: f8000000-f80fffff
> 	Prefetchable memory behind bridge: 00000000-000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 
> 00:02.0 PCI bridge: Marvell Technology Group Ltd. Device 6710 (rev 01) (prog-if 00 [Normal decode])
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
> 	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
> 	I/O behind bridge: 00010000-00010fff
> 	Memory behind bridge: f8100000-f81fffff
> 	Prefetchable memory behind bridge: 00000000-000fffff
> 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> 	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> 
> 01:00.0 USB controller: Fresco Logic FL1009 USB 3.0 Host Controller (rev 02) (prog-if 30 [XHCI])
> 	Subsystem: Fresco Logic Device 0000
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 107
> 	Region 0: Memory at f8000000 (64-bit, non-prefetchable) [size=64K]
> 	Region 2: Memory at f8010000 (64-bit, non-prefetchable) [size=4K]
> 	Region 4: Memory at f8011000 (64-bit, non-prefetchable) [size=4K]
> 	Capabilities: [40] Power Management version 3
> 		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=375mA PME(D0+,D1+,D2-,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [50] MSI: Enable+ Count=1/8 Maskable- 64bit+
> 		Address: 00000000d0020a04  Data: 0f11
> 	Capabilities: [70] Express (v2) Endpoint, MSI 00
> 		DevCap:	MaxPayload 512 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
> 			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> 			MaxPayload 128 bytes, MaxReadReq 512 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> 		LnkCap:	Port #0, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 unlimited, L1 unlimited
> 			ClockPM- Surprise- LLActRep- BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		DevCap2: Completion Timeout: Not Supported, TimeoutDis+
> 		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> 		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
> 			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> 	Capabilities: [b0] MSI-X: Enable- Count=8 Masked-
> 		Vector table: BAR=2 offset=00000000
> 		PBA: BAR=4 offset=00000000
> 	Capabilities: [100 v1] Advanced Error Reporting
> 		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> 		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
> 		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> 		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
> 	Kernel driver in use: xhci_hcd
> 
> 02:00.0 SATA controller: Marvell Technology Group Ltd. Device 9215 (rev 11) (prog-if 01 [AHCI 1.0])
> 	Subsystem: Marvell Technology Group Ltd. Device 9215
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 106
> 	Region 0: I/O ports at 10020 [size=8]
> 	Region 1: I/O ports at 10030 [size=4]
> 	Region 2: I/O ports at 10028 [size=8]
> 	Region 3: I/O ports at 10034 [size=4]
> 	Region 4: I/O ports at 10000 [size=32]
> 	Region 5: Memory at f8110000 (32-bit, non-prefetchable) [size=2K]
> 	Expansion ROM at f8100000 [disabled] [size=64K]
> 	Capabilities: [40] Power Management version 3
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit-
> 		Address: d0020a04  Data: 0f10
> 	Capabilities: [70] Express (v2) Legacy Endpoint, MSI 00
> 		DevCap:	MaxPayload 512 bytes, PhantFunc 0, Latency L0s <1us, L1 <8us
> 			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> 			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
> 			MaxPayload 128 bytes, MaxReadReq 512 bytes
> 		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> 		LnkCap:	Port #0, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <512ns, L1 <64us
> 			ClockPM- Surprise- LLActRep- BwNot-
> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> 		LnkSta:	Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> 		DevCap2: Completion Timeout: Not Supported, TimeoutDis+
> 		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> 		LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
> 			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> 			 Compliance De-emphasis: -6dB
> 		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
> 			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> 	Capabilities: [e0] SATA HBA v0.0 BAR4 Offset=00000004
> 	Capabilities: [100 v1] Advanced Error Reporting
> 		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> 		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> 		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
> 		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> 		AERCap:	First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
> 	Kernel driver in use: ahci



-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
