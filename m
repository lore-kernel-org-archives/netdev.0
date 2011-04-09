From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Sat, 9 Apr 2011 14:12:31 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E48BA6C0@ESGSCCMS0001.eapac.ericsson.se>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	 <1302163650.3357.8.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	 <1302167168.3357.12.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>
	 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
	 <1302253651.4409.2.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
	 <4D9F3629.9020506@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA6AF@ESGSCCMS0001.eapac.ericsson.se>
 <1302324057.15899.20.camel@ahduyck-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alexander H Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:55834 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258Ab1DIGMg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2011 02:12:36 -0400
In-Reply-To: <1302324057.15899.20.camel@ahduyck-mobl2.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,
The total thruput with 400byte UDP  receiving(terminate on prerouting hook) on 2.6.32 is over >1.5Mpps without packet lost.
I even tried forward this receved packets back on same NIC, I get >1.5Mpps Rx with same amount of Tx, no rx_missing_error at all. And even with some 68byte packets I was reach 5Mpps+/NIC on 2.6.32 kernel.

I was expect to gain even higher performance with this new linux kernel with same HW configuration.

Yes, the DMAR is off, I can get +1Mpps,but as I said not stable at all.(high rx_missing_error rate).

I'm sure the slot for eth10 was x8 Gen2:
[ixgbe: eth10: ixgbe_probe: (PCI Express:5.0Gb/s:Width x8) 00:1b:21:6b:45:cc]

For the memory configuration, I was using the same server as I was testing with 2.6.32. I have total 64G * 4 merory which is 100% memory bandwidth with 4 sock CPUs, recommended by HP expert( 8 DIMM's per processor in slot Cartridge).

Does anything from Linux kernel will affact these memory configuration thing?

numactl  --hardware
available: 4 nodes (0-3)
node 0 cpus: 0 1 2 3 4 5 6 7 32 33 34 35 36 37 38 39
node 0 size: 65525 MB
node 0 free: 63226 MB
node 1 cpus: 8 9 10 11 12 13 14 15 40 41 42 43 44 45 46 47
node 1 size: 65536 MB
node 1 free: 63292 MB
node 2 cpus: 16 17 18 19 20 21 22 23 48 49 50 51 52 53 54 55
node 2 size: 65536 MB
node 2 free: 63366 MB
node 3 cpus: 24 25 26 27 28 29 30 31 56 57 58 59 60 61 62 63
node 3 size: 65535 MB
node 3 free: 63345 MB
node distances:
node   0   1   2   3
  0:  10  20  20  20
  1:  20  10  20  20
  2:  20  20  10  20
  3:  20  20  20  10

Lspci -vvv
8d:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit Network Connection (rev 01)
        Subsystem: Intel Corporation Ethernet Server Adapter X520-2
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx+
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 50
        Region 0: Memory at f0200000 (64-bit, non-prefetchable) [size=512K]
        Region 2: I/O ports at 8000 [size=32]
        Region 4: Memory at f0284000 (64-bit, non-prefetchable) [size=16K]
        [virtual] Expansion ROM at f0600000 [disabled] [size=512K]
        Capabilities: [40] Power Management version 3
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] MSI: Enable- Count=1/1 Maskable+ 64bit+
                Address: 0000000000000000  Data: 0000
                Masking: 00000000  Pending: 00000000
        Capabilities: [70] MSI-X: Enable+ Count=64 Masked-
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00002000
        Capabilities: [a0] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
                DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
                        MaxPayload 256 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr- FatalErr+ UnsuppReq+ AuxPwr- TransPend+
                LnkCap: Port #2, Speed 5GT/s, Width x8, ASPM L0s, Latency L0 unlimited, L1 <32us
                        ClockPM- Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
                DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
                LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -6dB
        Capabilities: [100] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                UESvrt: DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ RxOF+ MalfTLP+ ECRC- UnsupReq+ ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                CEMsk:  RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
        Capabilities: [140] Device Serial Number 00-1b-21-ff-ff-6b-45-18
        Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
                ARICap: MFVC- ACS-, Next Function: 1
                ARICtl: MFVC- ACS-, Function Group: 0
        Capabilities: [160] Single Root I/O Virtualization (SR-IOV)
                IOVCap: Migration-, Interrupt Message Number: 000
                IOVCtl: Enable- Migration- Interrupt- MSE- ARIHierarchy+
                IOVSta: Migration-
                Initial VFs: 64, Total VFs: 64, Number of VFs: 64, Function Dependency Link: 00
                VF offset: 128, stride: 2, Device ID: 10ed
                Supported Page Size: 00000553, System Page Size: 00000001
                Region 0: Memory at 0000000000000000 (64-bit, non-prefetchable)
                Region 3: Memory at 0000000000000000 (64-bit, non-prefetchable)
                VF Migration: offset: 00000000, BIR: 0
        Kernel driver in use: ixgbe
        Kernel modules: ixgbe

Thanks
WeiGu

-----Original Message-----
From: Alexander H Duyck [mailto:alexander.h.duyck@intel.com]
Sent: Saturday, April 09, 2011 12:41 PM
To: Wei Gu
Cc: Eric Dumazet; netdev; Kirsher, Jeffrey T
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

On Fri, 2011-04-08 at 20:36 -0700, Wei Gu wrote:
> Hi Alexander, I do agree with you that if only the rx_missing_error
> (rx_no_buffer_count: 0) indicates the memory bandwidth issue. But the
> strange thing is I using the same test configuration on Linux 2.6.32,
> which looks no this problem at all. SO it not a HW setup problem at
> all, only difference in on the Kernel version, that's why I go back to
> you guys for this new Linux 2.6.38, if it will affact this memory
> bandwidth Or BIOS etc things?

What were the numbers you were getting with 2.6.32?  I would be interested in seeing those number just to get an idea of how they compare against the 2.6.38 kernel.

> The follow dump is done, while I was try to receive 290Kpps 400Byte
> pakets from IXIA, and drop them in the prerouting hook. I bind the
> eth10 8 RX queue to CPU sock ID 3 ( core 24-31) on NUMA NODE3

Just to confirm this is with DMAR off?  I saw an earlier email that said you were getting a variable amount that was over 1Mpps and just want to confirm this is with the same config.

> ethtool -i eth10
> driver: ixgbe
> version: 3.2.10-NAPI
> firmware-version: 0.9-3
> bus-info: 0000:8d:00.0
>
> ethtool -S eth10
> NIC statistics:
>      rx_packets: 14222510
>      tx_packets: 109
>      rx_bytes: 5575223920
>      tx_bytes: 17790
>      rx_missed_errors: 15150244
>      rx_no_buffer_count: 0

I trimmed down your stats here pretty significantly.  This isn't an issue with the driver not keeping up.  The problem here is memory and/or bus bandwidth.  Based on the info you provided I am assuming you have a quad socket system.  I'm curious how the memory is laid out.  What is the total memory size, memory per node, and do you have all of the memory channels on each node populated?  One common thing I've seen cause these type of issues is an incorrect memory configuration.

Also if you could send me an lspci -vvv for 8d:00.0 specifically I would appreciate it as I would like to look over the PCIe config just to make sure the slot is a x8 PCIe gen 2.

Thanks,

Alex

