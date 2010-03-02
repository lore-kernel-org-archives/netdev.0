From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Tue, 2 Mar 2010 09:20:20 +0100
Message-ID: <20100302092020.52cfcd0e@pluto.restena.lu>
References: <20091229084929.54912c0c@pluto.restena.lu>
	<1262077540.12520.4.camel@localhost>
	<20091229145403.39f82773@pluto.restena.lu>
	<1262149691.2788.63.camel@localhost>
	<20100219091034.5fbb0165@pluto.restena.lu>
	<1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com>
	<20100223131508.4c6cb866@neptune.home>
	<1267493170.2762.45.camel@dhcp-10-12-137-104.broadcom.com>
	<20100302081051.3d1b1c53@pluto.restena.lu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDEV <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: "Benjamin Li" <benli@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100302081051.3d1b1c53@pluto.restena.lu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Benjamin,

> The running kernel is 2.6.33-rc8 (though I did not forward-port your
> patch in this thread, that is bnx2_dump_ftq() is missing - half of it
> having been applied to 2.6.33). Looking at the trace I got I will add
> that part and try again.

Here it is with bnx2_dump_ftq added:

[ 3405.422963] ------------[ cut here ]------------
[ 3405.428958] WARNING: at /usr/src/linux-2.6.33-rc8-git7/kernel/softirq.c:143 local_bh_enable_ip+0x72/0xa0()
[ 3405.431858] Hardware name: ProLiant DL360 G5
[ 3405.431858] Modules linked in: netbomb bnx2 ipmi_devintf loop dm_mod sg sr_mod cdrom ata_piix ahci ipmi_si ipmi_msghandler uhci_hcd qla2xxx libata hpwdt ehci_hcd [last unloaded: bnx2]
[ 3405.431858] Pid: 25763, comm: cat Not tainted 2.6.33-rc8-git7-x86_64 #1
[ 3405.431858] Call Trace:
[ 3405.431858]  [<ffffffff8103f002>] ? local_bh_enable_ip+0x72/0xa0
[ 3405.431858]  [<ffffffff81039368>] warn_slowpath_common+0x78/0xd0
[ 3405.431858]  [<ffffffff810393cf>] warn_slowpath_null+0xf/0x20
[ 3405.431858]  [<ffffffff8103f002>] local_bh_enable_ip+0x72/0xa0
[ 3405.431858]  [<ffffffff814002af>] _raw_spin_unlock_bh+0xf/0x20
[ 3405.431858]  [<ffffffffa0108ed4>] bnx2_reg_rd_ind+0x44/0x60 [bnx2]
[ 3405.431858]  [<ffffffffa0108eff>] bnx2_shmem_rd+0xf/0x20 [bnx2]
[ 3405.431858]  [<ffffffffa0113464>] bnx2_poll+0x194/0x228 [bnx2]
[ 3405.431858]  [<ffffffff8135c081>] netpoll_poll+0xe1/0x3c0
[ 3405.431858]  [<ffffffff8135c518>] netpoll_send_skb+0x118/0x210
[ 3405.431858]  [<ffffffff8135c80b>] netpoll_send_udp+0x1fb/0x210
[ 3405.431858]  [<ffffffffa00131c5>] write_msg+0x95/0xd0 [netbomb]
[ 3405.431858]  [<ffffffffa0013255>] netbomb_write+0x55/0xa4 [netbomb]
[ 3405.431858]  [<ffffffff810f6571>] proc_reg_write+0x71/0xb0
[ 3405.431858]  [<ffffffff810ab6db>] vfs_write+0xcb/0x180
[ 3405.431858]  [<ffffffff810ab880>] sys_write+0x50/0x90
[ 3405.431858]  [<ffffffff8102a1a4>] sysenter_dispatch+0x7/0x2b
[ 3405.431858] ---[ end trace b4ac1510884bf2bc ]---
[ 3411.050005] ------------[ cut here ]------------
[ 3411.054851] WARNING: at /usr/src/linux-2.6.33-rc8-git7/net/sched/sch_generic.c:255 dev_watchdog+0x25e/0x270()
[ 3411.059546] Hardware name: ProLiant DL360 G5
[ 3411.061569] NETDEV WATCHDOG: eth0 (bnx2): transmit queue 0 timed out
[ 3411.064582] Modules linked in: netbomb bnx2 ipmi_devintf loop dm_mod sg sr_mod cdrom ata_piix ahci ipmi_si ipmi_msghandler uhci_hcd qla2xxx libata hpwdt ehci_hcd [last unloaded: bnx2]
[ 3411.064597] Pid: 0, comm: swapper Tainted: G        W  2.6.33-rc8-git7-x86_64 #1
[ 3411.064599] Call Trace:
[ 3411.064601]  <IRQ>  [<ffffffff8135f84e>] ? dev_watchdog+0x25e/0x270
[ 3411.064609]  [<ffffffff81039368>] warn_slowpath_common+0x78/0xd0
[ 3411.064612]  [<ffffffff81039444>] warn_slowpath_fmt+0x64/0x70
[ 3411.064616]  [<ffffffff8103486d>] ? default_wake_function+0xd/0x10
[ 3411.064620]  [<ffffffff8119f339>] ? strlcpy+0x49/0x60
[ 3411.064623]  [<ffffffff81349b33>] ? netdev_drivername+0x43/0x50
[ 3411.064626]  [<ffffffff8135f84e>] dev_watchdog+0x25e/0x270
[ 3411.064630]  [<ffffffff8104c000>] ? delayed_work_timer_fn+0x0/0x40
[ 3411.064633]  [<ffffffff8104bf87>] ? __queue_work+0x77/0x90
[ 3411.064636]  [<ffffffff8103558b>] ? scheduler_tick+0x1bb/0x290
[ 3411.064639]  [<ffffffff8135f5f0>] ? dev_watchdog+0x0/0x270
[ 3411.064642]  [<ffffffff810440fc>] run_timer_softirq+0x13c/0x210
[ 3411.064645]  [<ffffffff8105b4b7>] ? clockevents_program_event+0x57/0xa0
[ 3411.064649]  [<ffffffff8103edb6>] __do_softirq+0xa6/0x130
[ 3411.064652]  [<ffffffff81003bcc>] call_softirq+0x1c/0x30
[ 3411.064655]  [<ffffffff81005be5>] do_softirq+0x55/0x90
[ 3411.064658]  [<ffffffff8103eb35>] irq_exit+0x75/0x90
[ 3411.064661]  [<ffffffff8101aeed>] smp_apic_timer_interrupt+0x6d/0xa0
[ 3411.064664]  [<ffffffff81003693>] apic_timer_interrupt+0x13/0x20
[ 3411.064666]  <EOI>  [<ffffffff8100b186>] ? mwait_idle+0x66/0x80
[ 3411.064670]  [<ffffffff81001f90>] ? enter_idle+0x20/0x30
[ 3411.064673]  [<ffffffff81002003>] cpu_idle+0x63/0xb0
[ 3411.064676]  [<ffffffff813f2f14>] rest_init+0x74/0x80
[ 3411.064680]  [<ffffffff81880c15>] start_kernel+0x2f8/0x336
[ 3411.064683]  [<ffffffff8188026d>] x86_64_start_reservations+0x7d/0x84
[ 3411.064686]  [<ffffffff81880354>] x86_64_start_kernel+0xe0/0xf2
[ 3411.064688] ---[ end trace b4ac1510884bf2bd ]---
[ 3411.064689] bnx2: <--- start FTQ dump on eth0 --->
[ 3411.064691] bnx2: eth0: BNX2_RV2P_PFTQ_CTL 10000
[ 3411.064693] bnx2: eth0: BNX2_RV2P_TFTQ_CTL 20000
[ 3411.064695] bnx2: eth0: BNX2_RV2P_MFTQ_CTL 20000
[ 3411.064697] bnx2: eth0: BNX2_TBDR_FTQ_CTL 4002
[ 3411.064699] bnx2: eth0: BNX2_TDMA_FTQ_CTL 10002
[ 3411.064702] bnx2: eth0: BNX2_TXP_FTQ_CTL 10002
[ 3411.064704] bnx2: eth0: BNX2_TPAT_FTQ_CTL 10002
[ 3411.064706] bnx2: eth0: BNX2_RXP_CFTQ_CTL 8000
[ 3411.064708] bnx2: eth0: BNX2_RXP_FTQ_CTL 100000
[ 3411.064710] bnx2: eth0: BNX2_COM_COMXQ_FTQ_CTL 10000
[ 3411.064712] bnx2: eth0: BNX2_COM_COMTQ_FTQ_CTL 20000
[ 3411.064715] bnx2: eth0: BNX2_COM_COMQ_FTQ_CTL 10000
[ 3411.064717] bnx2: eth0: BNX2_CP_CPQ_FTQ_CTL 8000
[ 3411.064724] bnx2: eth0: TXP mode b84c state 80001000 evt_mask 500 pc 8000bcc pc 8000bec instr 30620001
[ 3411.064732] bnx2: eth0: TPAT mode b84c state 80005000 evt_mask 500 pc 8000694 pc 80006a4 instr 8e310458
[ 3411.064740] bnx2: eth0: RXP mode b84c state 80001000 evt_mask 500 pc 80044a8 pc 80044a8 instr ac2400f8
[ 3411.064748] bnx2: eth0: COM mode b84c state 80001000 evt_mask 500 pc 8000a60 pc 8000a74 instr 3c030800
[ 3411.064756] bnx2: eth0: CP mode b84c state 80008000 evt_mask 500 pc 8000434 pc 8000700 instr 39ee0001
[ 3411.064758] bnx2: <--- end FTQ dump on eth0 --->
[ 3411.064759] bnx2: eth0 DEBUG: intr_sem[0]
[ 3411.064762] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[ 3411.064766] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[ 3411.064768] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[ 3416.050005] bnx2: <--- start FTQ dump on eth0 --->
[ 3416.054456] bnx2: eth0: BNX2_RV2P_PFTQ_CTL 10000
[ 3416.057683] bnx2: eth0: BNX2_RV2P_TFTQ_CTL 20000
[ 3416.059944] bnx2: eth0: BNX2_RV2P_MFTQ_CTL 20000
[ 3416.069481] bnx2: eth0: BNX2_TBDR_FTQ_CTL 4002
[ 3416.078819] bnx2: eth0: BNX2_TDMA_FTQ_CTL 10002
[ 3416.083896] bnx2: eth0: BNX2_TXP_FTQ_CTL 10002
[ 3416.085968] bnx2: eth0: BNX2_TPAT_FTQ_CTL 10002
[ 3416.088084] bnx2: eth0: BNX2_RXP_CFTQ_CTL 8000
[ 3416.090129] bnx2: eth0: BNX2_RXP_FTQ_CTL 100000
[ 3416.092285] bnx2: eth0: BNX2_COM_COMXQ_FTQ_CTL 10000
[ 3416.096710] bnx2: eth0: BNX2_COM_COMTQ_FTQ_CTL 20000
[ 3416.099065] bnx2: eth0: BNX2_COM_COMQ_FTQ_CTL 10000
[ 3416.101506] bnx2: eth0: BNX2_CP_CPQ_FTQ_CTL 8000
[ 3416.105567] bnx2: eth0: TXP mode b84c state 80001000 evt_mask 500 pc 8000bf0 pc 8000bc0 instr b8302b
[ 3416.109963] bnx2: eth0: TPAT mode b84c state 80001000 evt_mask 500 pc 8000674 pc 8000694 instr af8d0034
[ 3416.120862] bnx2: eth0: RXP mode b84c state 80001000 evt_mask 500 pc 80044c4 pc 800447c instr 3c050800
[ 3416.125237] bnx2: eth0: COM mode b84c state 80001000 evt_mask 500 pc 8000a1c pc 8000a28 instr 8c4200b8
[ 3416.130656] bnx2: eth0: CP mode b84c state 80000000 evt_mask 500 pc 8000728 pc 800040c instr 18d2821
[ 3416.139721] bnx2: <--- end FTQ dump on eth0 --->
[ 3416.142905] bnx2: eth0 DEBUG: intr_sem[0]
[ 3416.145814] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[ 3416.151452] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[ 3416.154701] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
...


Regards,
Bruno
