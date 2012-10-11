From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: Fwd: [Bug 1063038] Re: Broadcom BCM57780 Cannot Connect at
 Gigabit Speed using tg3 module.
Date: Thu, 11 Oct 2012 13:25:50 -0700
Message-ID: <50772B4E.6050209@broadcom.com>
References: <20121009143846.2196.28573.malone@chaenomeles.canonical.com>
 <50756903.1030709@justinzane.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 1063038@bugs.launchpad.net
To: "Justin Chudgar" <justin@justinzane.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2287 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755828Ab2JKX66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2012 19:58:58 -0400
In-Reply-To: <50756903.1030709@justinzane.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 10/10/2012 05:24 AM, Justin Chudgar wrote:
> I've got a device with a Broadcom 57780 ethernet NIC. It uses the tg3.ko
> driver module. The problem is that this NIC cannot connect at gigabit
> (1000MBps) speed. In all cases connection works well at 100MBps. I
> reported this to Ubuntu as noted below and was directed here.
> [https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1063038] Following
> are the tests I've completed:


I don't see a problem linking up with 57780 at gigabit. I tested the latest net kernel (3.6.0) and 
to make sure it's not ubuntu specific, tested ubuntu 12.04 as well (3.2.0.23-generic). Everything 
works fine here on my setup.


 > sudo ethtool -i eth7
driver: tg3
version: 3.121
firmware-version: 57780-v3.15
bus-info: 0000:43:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes


 > sudo ethtool eth7
     Settings for eth7:
     Supported ports: [ TP MII ]
     Supported link modes: 10baseT/Half 10baseT/Full
                           100baseT/Half 100baseT/Full
                           1000baseT/Half 1000baseT/Full
     Supported pause frame use: Symmetric Receive-only
     Supports auto-negotiation: Yes
     Advertised link modes: 10baseT/Half 10baseT/Full
                            100baseT/Half 100baseT/Full
                            1000baseT/Half 1000baseT/Full
     Advertised pause frame use: Symmetric Receive-only
     Advertised auto-negotiation: Yes
     Speed: 1000Mb/s
     Duplex: Full
     Port: MII
     PHYAD: 1
     Transceiver: external
     Auto-negotiation: on
     Supports Wake-on: g
     Wake-on: d
     Current message level: 0x000000ff (255)
     drv probe link timer ifdown ifup rx_err tx_err
     Link detected: yes


 > ifconfig eth7
eth7 Link encap:Ethernet HWaddr 00:10:18:2a:18:cd
inet addr:3.3.3.1 Bcast:3.3.3.255 Mask:255.255.255.0
inet6 addr: fe80::210:18ff:fe2a:18cd/64 Scope:Link
UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
RX packets:1224 errors:0 dropped:0 overruns:0 frame:0
TX packets:1114 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:115500 (115.5 KB) TX bytes:146587 (146.5 KB)
Interrupt:80

 > ping 3.3.3.2 -c 1
PING 3.3.3.2 (3.3.3.2) 56(84) bytes of data.
64 bytes from 3.3.3.2: icmp_req=1 ttl=64 time=0.185 ms

--- 3.3.3.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.185/0.185/0.185/0.000 ms


Nithin.

> - Cables tested with cable tester
> - Cables tested to work at gigabit speed with Realtek and Intel gigabit
> NICs.
> - All unmanaged switch ports tested at gigabit speed with other NICs.
> - Tried to connect with NetworkManager enabled and disabled.
> - Tried both dhcp and static connections.
> - Tried to renegotiate connection with `ethtool -r` both with TSO
> enabled and disabled.
> - Tried 3.2.0-23-generic 3.5.0-15-generic3.5.0-17-generic
> 3.6.0-999-generic kernels from main, xorg-edgers and mainline repos.
> - Used 'tg3_debug=1' kernel option in grub with the following output:
>
>      [ 0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.5.0-17-generic
> root=UUID=eccabacd-efb2-45b4-b7a6-2f530d50afd3 ro rootflags=subvol=@
> tg3_debug=1 i915_enable_rc6=7 i915_enable_fbc=1 lvds_downclock=1
>      [ 0.000000] Kernel command line:
> BOOT_IMAGE=/vmlinuz-3.5.0-17-generic
> root=UUID=eccabacd-efb2-45b4-b7a6-2f530d50afd3 ro rootflags=subvol=@
> tg3_debug=1 i915_enable_rc6=7 i915_enable_fbc=1 lvds_downclock=1
>      [ 5.963136] tg3.c:v3.123 (March 21, 2012)
>      [ 5.995781] tg3 mdio bus: probed
>      [ 6.005583] tg3 0000:01:00.0: >eth0: Tigon3 [partno(BCM57780) rev
> 57780001] (PCI Express) MAC address dc:0e:a1:ac:38:d5
>      [ 6.005687] tg3 0000:01:00.0: >eth0: attached PHY driver [Broadcom
> BCM57780] (mii_bus:phy_addr=100:01)
>      [ 6.005790] tg3 0000:01:00.0: >eth0: RXcsums[1] LinkChgREG[0]
> MIirq[0] ASF[0] TSOcap[1]
>      [ 6.005887] tg3 0000:01:00.0: >eth0: dma_rwctrl[76180000]
> dma_mask[64-bit]
>      [ 294.987653] tg3 0000:01:00.0: >irq 44 for MSI/MSI-X
>      [ 295.893224] tg3 0000:01:00.0: >eth0: Link is down
>      [ 309.887879] tg3 0000:01:00.0: >eth0: Link is up at 100 Mbps, full
> duplex
>      [ 309.887886] tg3 0000:01:00.0: >eth0: Flow control is on for TX and
> on for RX
>
> Other distros' forums suggest loading broadcom.ko first; however, this
> module is no present. Any suggestions would be much appreciated.
>
> lspci -vv:
>      01:00.0 Ethernet controller: Broadcom Corporation NetLink BCM57780
> Gigabit Ethernet PCIe (rev 01)
>          Subsystem: Acer Incorporated [ALI] Device 0601
>          Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>          Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>          Latency: 0, Cache Line Size: 64 bytes
>          Interrupt: pin A routed to IRQ 44
>          Region 0: Memory at d3400000 (64-bit, non-prefetchable) [size=64K]
>          Capabilities: [48] Power Management version 3
>                  Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot+,D3cold+)
>
>                  Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=1 PME-
>          Capabilities: [60] Vendor Specific Information: Len=6c <?>
>          Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
>                  Address: 00000000fee0100c Data: 4189
>          Capabilities: [cc] Express (v2) Endpoint, MSI 00
>                  DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
> <4us, L1 unlimited
>                          ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
>                  DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
> Unsupported-
>                          RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                          MaxPayload 128 bytes, MaxReadReq 512 bytes
>                  DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr+
> TransPend+
>                  LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
> Latency L0 <1us, L1 <32us
>                          ClockPM+ Surprise- LLActRep- BwNot-
>                  LnkCtl: ASPM L0s L1 Enabled; RCB 64 bytes Disabled-
> Retrain- CommClk+
>                          ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
>                  LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
> DLActive- BWMgmt- ABWMgmt-
>                  DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
>                  DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
>                  LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance-
> SpeedDis-, Selectable De-emphasis: -6dB
>                           Transmit Margin: Normal Operating Range,
> EnterModifiedCompliance- ComplianceSOS-
>                           Compliance De-emphasis: -6dB
>                  LnkSta2: Current De-emphasis Level: -6dB
>          Capabilities: [100 v1] Advanced Error Reporting
>                  UESta: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                  UEMsk: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                  UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
>                  CESta: RxErr+ BadTLP- BadDLLP- Rollover- Timeout-
> NonFatalErr-
>                  CEMsk: RxErr- BadTLP- BadDLLP- Rollover- Timeout-
> NonFatalErr+
>                  AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+
> ChkEn-
>          Capabilities: [13c v1] Virtual Channel
>                  Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
>                  Arb: Fixed- WRR32- WRR64- WRR128-
>                  Ctrl: ArbSelect=Fixed
>                  Status: InProgress-
>                  VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>                          Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
>                          Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
>                          Status: NegoPending- InProgress-
>          Capabilities: [160 v1] Device Serial Number dc-0e-a1-ff-fe-ac-38-d5
>          Capabilities: [16c v1] Power Budgeting <?>
>          Kernel driver in use: tg3
>          Kernel modules: tg3
> ---
>
>
> Justin Chudgar  |  Weed, CA 96094  |  530 921 0738 | http://www.justinzane.com/
>
> -------- Original Message --------
> Subject: 	[Bug 1063038] Re: Broadcom BCM57780 Cannot Connect at Gigabit
> Speed using tg3 module.
> Date: 	Tue, 09 Oct 2012 14:38:45 -0000
> From: 	Joseph Salisbury <joseph.salisbury@canonical.com>
> Reply-To: 	Bug 1063038 <1063038@bugs.launchpad.net>
> To: 	justin@justinzane.com
>
>
>
> This issue appears to be an upstream bug, since you tested the latest
> upstream kernel.  Would it be possible for you to open an upstream bug
> report[0]?  That will allow the upstream Developers to examine the
> issue, and may provide a quicker resolution to the bug.
>
> Please follow the instructions on the wiki page[0].  The first step is
> to email the appropriate mailing list.  If no response is received, then
> a bug may be opened on bugzilla.kernel.org.
>
> [0] https://wiki.ubuntu.com/Bugs/Upstream/kernel
>
>
> ** Changed in: linux (Ubuntu)
>         Status: Confirmed => Triaged
>
> ** Changed in: linux (Ubuntu)
>     Importance: Undecided => Medium
>
> ** Tags added: kernel-bug-exists-upstream
>
