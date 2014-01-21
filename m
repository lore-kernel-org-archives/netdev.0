From: Craig Small <csmall@enc.com.au>
Subject: r8169 won't transmit with 3.12
Date: Tue, 21 Jan 2014 11:06:15 +1100
Message-ID: <20140121000615.GA30495@enc.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:44148 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750822AbaAUAGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 19:06:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
  I seem to be having lots of troubles with the RealTek chipsets. I have
one onboard and two PCI-e cards and they all have the same problem. They
will not transmit anything.  The r8169 driver does it, as does the 
r8168-dkms module.

It's a new setup so it might of never worked. It's not likely to be a
hardware problem as its three different devices.

I've sent what I think you might need for starters, but if there
is extra stuff you'd like to see, let me know.

I'm using a stock Debian kernel
3.12-1-amd64 #1 SMP Debian 3.12.6-2 (2013-12-29)

I've included the lspci output of one of the cards below. I'm not
really sure what else you'd need to check things.

The problem shows up the same, the TX dropped counter increments.
I'm not sure why 42 packets made it out (or even if they really did)
Receive works fine, I can even start up wireshark and see packets
pass by.

eth0      Link encap:Ethernet  HWaddr 00:e0:4c:80:66:57  
          inet addr:192.168.1.222  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::2e0:4cff:fe80:6657/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8252 errors:0 dropped:0 overruns:0 frame:0
          TX packets:42 errors:0 dropped:8029 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:584930 (571.2 KiB)  TX bytes:5083 (4.9 KiB)

ethtool -S shows a similar story, not sure if the rx_missed counter
is another problem:
NIC statistics:
     tx_packets: 47
     rx_packets: 31342
     tx_errors: 0
     rx_errors: 0
     rx_missed: 47438
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 1
     broadcast: 29638
     multicast: 1891
     tx_aborted: 0
     tx_underrun: 0

I've disabled the on-board device now, but the simple lspci output was:
03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 06)

The PCI-e cards have the following:

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 02)
	Subsystem: Realtek Semiconductor Co., Ltd. RTL8111/8168 PCI Express Gigabit Ethernet controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 73
	Region 0: I/O ports at d000 [size=256]
	Region 2: Memory at fde00000 (64-bit, non-prefetchable) [size=4K]
	Region 4: Memory at d2200000 (64-bit, prefetchable) [size=64K]
	Expansion ROM at d2210000 [disabled] [size=64K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee3f00c  Data: 4123
	Capabilities: [70] Express (v1) Endpoint, MSI 08
		DevCap:	MaxPayload 1024 bytes, PhantFunc 0, Latency L0s <128ns, L1 unlimited
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend+
		LnkCap:	Port #16, Speed unknown, Width x22, ASPM not supported, Exit Latency L0s <64ns, L1 <2us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [b0] MSI-X: Enable- Count=2 Masked-
		Vector table: BAR=4 offset=00000000
		PBA: BAR=4 offset=00000800
	Capabilities: [d0] Vital Product Data
		Unknown small resource type 05, will not decode more.
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr+ BadTLP+ BadDLLP+ Rollover- Timeout- NonFatalErr-
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [140 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number 00-00-00-00-00-00-00-00
	Kernel driver in use: r8169

-- 
Craig Small (@smallsees)   http://enc.com.au/       csmall at : enc.com.au
Debian GNU/Linux           http://www.debian.org/   csmall at : debian.org
GPG fingerprint:        5D2F B320 B825 D939 04D2  0519 3938 F96B DF50 FEA5
