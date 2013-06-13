From: Johannes Stezenbach <js@sig21.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Fri, 14 Jun 2013 00:24:11 +0200
Message-ID: <20130613222411.GA5396@sig21.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com, romieu@fr.zoreil.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:56800 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757878Ab3FMWYT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 18:24:19 -0400
Content-Disposition: inline
In-Reply-To: <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 12, 2013 at 10:33:22PM +0200, Johannes Berg wrote:
> This is a very simple driver, based on the original vendor
> driver that Qualcomm/Atheros published/submitted previously.
> I have heavily reworked the driver to be a bit saner, and
> in the process removed a number of features: TSO/GSO, VLAN
> acceleration and multiqueue. I've also ruthlessly stripped
> things not useful to me, e.g. register access support.
> 
> Right now it only supports a single TX and RX queue and no
> special features other than checksum offload.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

I tried your driver with v3.9.6 and got this on boot:

[    0.939189] INFO: trying to register non-static key.
[    0.939787] the code is fine but needs lockdep annotation.
[    0.940387] turning off the locking correctness validator.
[    0.940992] Pid: 1, comm: swapper/0 Not tainted 3.9.6 #2
[    0.941589] Call Trace:
[    0.942179]  [<ffffffff8108cead>] __lock_acquire.isra.24+0x710/0xa47
[    0.942781]  [<ffffffff8108d87f>] lock_acquire+0xc0/0x142
[    0.943379]  [<ffffffff814414b1>] ? alx_write_phy_dbg+0x25/0x69
[    0.943980]  [<ffffffff8108b624>] ? lock_release_holdtime.part.18+0x93/0x98
[    0.944587]  [<ffffffff816620ae>] _raw_spin_lock+0x3e/0x70
[    0.945193]  [<ffffffff814414b1>] ? alx_write_phy_dbg+0x25/0x69
[    0.945798]  [<ffffffff814414b1>] alx_write_phy_dbg+0x25/0x69
[    0.946399]  [<ffffffff81441bcc>] alx_reset_phy+0x78/0x223
[    0.946991]  [<ffffffff814424b5>] ? alx_phy_configured+0x1a/0x7f
[    0.947577]  [<ffffffff8144000b>] alx_probe+0x30f/0x635
[    0.948162]  [<ffffffff812d54a8>] pci_device_probe+0x6e/0xb2
[    0.948757]  [<ffffffff813efab0>] driver_probe_device+0x11a/0x2ef
[    0.949350]  [<ffffffff813efd23>] __driver_attach+0x61/0x83
[    0.949936]  [<ffffffff813efcc2>] ? __device_attach+0x3d/0x3d
[    0.950513]  [<ffffffff813ede40>] bus_for_each_dev+0x7d/0x87
[    0.951089]  [<ffffffff813ef4e8>] driver_attach+0x1e/0x20
[    0.951661]  [<ffffffff813ef0b6>] bus_add_driver+0x136/0x23e
[    0.952228]  [<ffffffff81f0cf63>] ? atl1e_init_module+0x1b/0x1b
[    0.952782]  [<ffffffff813f0268>] driver_register+0x8c/0xfd
[    0.953321]  [<ffffffff81f0cf63>] ? atl1e_init_module+0x1b/0x1b
[    0.953855]  [<ffffffff812d5319>] __pci_register_driver+0x5d/0x60
[    0.954387]  [<ffffffff81f0cf7c>] alx_driver_init+0x19/0x1b
[    0.954906]  [<ffffffff8100026c>] do_one_initcall+0x7f/0x13e
[    0.955420]  [<ffffffff81ee0e96>] kernel_init_freeable+0x115/0x196
[    0.955922]  [<ffffffff81ee0738>] ? do_early_param+0x88/0x88
[    0.956436]  [<ffffffff81648389>] ? rest_init+0xbd/0xbd
[    0.956955]  [<ffffffff81648397>] kernel_init+0xe/0xd6
[    0.957472]  [<ffffffff8166962c>] ret_from_fork+0x7c/0xb0
[    0.958000]  [<ffffffff81648389>] ? rest_init+0xbd/0xbd

and after "ifconfig eth0 up":

[  539.482153] alx 0000:03:00.0: irq 45 for MSI/MSI-X
[  539.482249] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[  539.483169] alx 0000:03:00.0 eth0: NIC Up: 1 Gbps Full
[  539.483354] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  544.801438] ------------[ cut here ]------------
[  544.801458] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x19b/0x201()
[  544.801462] Hardware name: System Product Name
[  544.801464] NETDEV WATCHDOG: eth0 (alx): transmit queue 0 timed out
[  544.801466] Modules linked in: ath9k_htc ath9k_common ath9k_hw kvm_intel ath mac80211 kvm cfg80211 ehci_pci ehci_hcd xhci_hcd
[  544.801483] Pid: 0, comm: swapper/2 Not tainted 3.9.6 #2
[  544.801486] Call Trace:
[  544.801488]  <IRQ>  [<ffffffff8155e600>] ? dev_watchdog+0x118/0x201
[  544.801499]  [<ffffffff8103f68c>] warn_slowpath_common+0x81/0x9b
[  544.801513]  [<ffffffff8103f6f2>] warn_slowpath_fmt+0x4c/0x4e
[  544.801525]  [<ffffffff8155e683>] dev_watchdog+0x19b/0x201
[  544.801530]  [<ffffffff8155e4e8>] ? dev_graft_qdisc+0x6b/0x6b
[  544.801536]  [<ffffffff8104cbb1>] call_timer_fn+0xa1/0x1b7
[  544.801540]  [<ffffffff8104cb15>] ? call_timer_fn+0x5/0x1b7
[  544.801545]  [<ffffffff8104d4eb>] run_timer_softirq+0x1f2/0x253
[  544.801550]  [<ffffffff8155e4e8>] ? dev_graft_qdisc+0x6b/0x6b
[  544.801555]  [<ffffffff81046902>] __do_softirq+0x106/0x28e
[  544.801560]  [<ffffffff81046bb4>] irq_exit+0x66/0xaa
[  544.801572]  [<ffffffff8166b0ad>] smp_apic_timer_interrupt+0x8a/0x98
[  544.801585]  [<ffffffff8166a2f2>] apic_timer_interrupt+0x72/0x80
[  544.801587]  <EOI>  [<ffffffff814cdc09>] ? cpuidle_wrap_enter+0x4f/0x87
[  544.801602]  [<ffffffff814cd3f5>] cpuidle_enter_tk+0x10/0x12
[  544.801618]  [<ffffffff814cd7d1>] cpuidle_enter_state+0x13/0x39
[  544.801626]  [<ffffffff814cd8f6>] cpuidle_idle_call+0xff/0x1f5
[  544.801634]  [<ffffffff8100920c>] cpu_idle+0xb5/0xf3
[  544.801643]  [<ffffffff816519cc>] start_secondary+0x266/0x26a
[  544.801650] ---[ end trace bf3b629fdf5b91ce ]---
[  544.803253] alx 0000:03:00.0 eth0: NIC Up: 1 Gbps Full


lspci -vvvn:

03:00.0 Ethernet controller: Qualcomm Atheros AR8161 Gigabit Ethernet (rev 08)

03:00.0 0200: 1969:1091 (rev 08)
	Subsystem: 1043:8507
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx+
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 45
	Region 0: Memory at f7c00000 (64-bit, non-prefetchable) [size=256K]
	Region 2: I/O ports at e000 [size=128]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 4096 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- AttnBtn+ AttnInd+ PwrInd+ RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 unlimited, L1 unlimited
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [c0] MSI: Enable+ Count=1/16 Maskable+ 64bit+
		Address: 00000000fee0f00c  Data: 41e1
		Masking: 0000fffe  Pending: 00000000
	Capabilities: [d8] MSI-X: Enable- Count=16 Masked-
		Vector table: BAR=0 offset=00002000
		PBA: BAR=0 offset=00003000
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP- SDES+ TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [180 v1] Device Serial Number ff-*
	Kernel driver in use: alx


grep eth0 /proc/interrupts
 45:          0          0          0          0   PCI-MSI-edge      eth0


Any idea what to try?


Thanks,
Johannes
