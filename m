From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Tue, 2 Mar 2010 08:10:51 +0100
Message-ID: <20100302081051.3d1b1c53@pluto.restena.lu>
References: <20091229084929.54912c0c@pluto.restena.lu>
	<1262077540.12520.4.camel@localhost>
	<20091229145403.39f82773@pluto.restena.lu>
	<1262149691.2788.63.camel@localhost>
	<20100219091034.5fbb0165@pluto.restena.lu>
	<1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com>
	<20100223131508.4c6cb866@neptune.home>
	<1267493170.2762.45.camel@dhcp-10-12-137-104.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDEV <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: "Benjamin Li" <benli@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267493170.2762.45.camel@dhcp-10-12-137-104.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Benjamin,

On Mon, 1 Mar 2010 17:26:10 "Benjamin Li" <benli@broadcom.com> wrote:
> Thanks for trying the patch.  I still haven't been able to reproduce
> what you are seeing here.  I am able to run scp and 'echo t
> > /proc/sysrq-trigger' multiple times.  I was wondering if you had any
> success reproducing the problem with a stack trace?

Last week I couldn't trigger it again after booting with console=ttyS1,
but today I finally got the box to crash (same procedure but matter of
"luck" as to when it happens)

System continues printing the bnx2 debug messages but does not accept any
input (not even on serial console). Every few minutes it complains about
collectd being blocked for more than 120 seconds (collectd wants to send
UDP packets with system state)

The running kernel is 2.6.33-rc8 (though I did not forward-port your
patch in this thread, that is bnx2_dump_ftq() is missing - half of it
having been applied to 2.6.33). Looking at the trace I got I will add
that part and try again.

Regards,
Bruno

[575872.163771] ------------[ cut here ]------------
[575872.172467] WARNING: at /usr/src/linux-2.6.33-rc8-git7/kernel/softirq.c:143 local_bh_enable_ip+0x72/0xa0()
[575872.172890] Hardware name: ProLiant DL360 G5
[575872.172890] Modules linked in: qla2xxx netbomb ipmi_devintf loop dm_mod sg sr_mod cdrom ata_piix ahci uhci_hcd ipmi_si ipmi_msghandler hpwdt bnx2 ehci_hcd libata [last unloaded: qla2xxx]
[575872.172890] Pid: 32564, comm: cat Not tainted 2.6.33-rc8-git7-x86_64 #1
[575872.172890] Call Trace:
[575872.172890]  [<ffffffff8103f002>] ? local_bh_enable_ip+0x72/0xa0
[575872.172890]  [<ffffffff81039368>] warn_slowpath_common+0x78/0xd0
[575872.172890]  [<ffffffff810393cf>] warn_slowpath_null+0xf/0x20
[575872.172890]  [<ffffffff8103f002>] local_bh_enable_ip+0x72/0xa0
[575872.172890]  [<ffffffff814002af>] _raw_spin_unlock_bh+0xf/0x20
[575872.172890]  [<ffffffffa0026ed4>] bnx2_reg_rd_ind+0x44/0x60 [bnx2]
[575872.172890]  [<ffffffffa0026eff>] bnx2_shmem_rd+0xf/0x20 [bnx2]
[575872.172890]  [<ffffffffa0030ff4>] bnx2_poll+0x194/0x228 [bnx2]
[575872.172890]  [<ffffffff8135c081>] netpoll_poll+0xe1/0x3c0
[575872.172890]  [<ffffffff8135c518>] netpoll_send_skb+0x118/0x210
[575872.172890]  [<ffffffff8135c80b>] netpoll_send_udp+0x1fb/0x210
[575872.172890]  [<ffffffffa00501c5>] write_msg+0x95/0xd0 [netbomb]
[575872.172890]  [<ffffffffa0050255>] netbomb_write+0x55/0xa4 [netbomb]
[575872.172890]  [<ffffffff810f6571>] proc_reg_write+0x71/0xb0
[575872.172890]  [<ffffffff810ab6db>] vfs_write+0xcb/0x180
[575872.172890]  [<ffffffff810ab880>] sys_write+0x50/0x90
[575872.172890]  [<ffffffff8102a1a4>] sysenter_dispatch+0x7/0x2b
[575872.172890] ---[ end trace d4f601a1b34bd327 ]---
[575878.950008] ------------[ cut here ]------------
[575878.955297] WARNING: at /usr/src/linux-2.6.33-rc8-git7/net/sched/sch_generic.c:255 dev_watchdog+0x25e/0x270()
[575878.966541] Hardware name: ProLiant DL360 G5
[575878.972352] NETDEV WATCHDOG: eth0 (bnx2): transmit queue 0 timed out
[575878.976435] Modules linked in: qla2xxx netbomb ipmi_devintf loop dm_mod sg sr_mod cdrom ata_piix ahci uhci_hcd ipmi_si ipmi_msghandler hpwdt bnx2 ehci_hcd libata [last unloaded: qla2xxx]
[575878.985325] Pid: 0, comm: swapper Tainted: G        W  2.6.33-rc8-git7-x86_64 #1
[575878.988929] Call Trace:
[575878.990124]  <IRQ>  [<ffffffff8135f84e>] ? dev_watchdog+0x25e/0x270
[575878.994317]  [<ffffffff81039368>] warn_slowpath_common+0x78/0xd0
[575878.998118]  [<ffffffff81039444>] warn_slowpath_fmt+0x64/0x70
[575879.010352]  [<ffffffff81362206>] ? nlmsg_notify+0x46/0xc0
[575879.012956]  [<ffffffff8119f339>] ? strlcpy+0x49/0x60
[575879.015487]  [<ffffffff81349b33>] ? netdev_drivername+0x43/0x50
[575879.027713]  [<ffffffff8135f84e>] dev_watchdog+0x25e/0x270
[575879.030339]  [<ffffffff810354fc>] ? scheduler_tick+0x12c/0x290
[575879.034202]  [<ffffffff8135f5f0>] ? dev_watchdog+0x0/0x270
[575879.047296]  [<ffffffff810440fc>] run_timer_softirq+0x13c/0x210
[575879.051101]  [<ffffffff8105b4b7>] ? clockevents_program_event+0x57/0xa0
[575879.054422]  [<ffffffff8103edb6>] __do_softirq+0xa6/0x130
[575879.065396]  [<ffffffff81003bcc>] call_softirq+0x1c/0x30
[575879.070825]  [<ffffffff81005be5>] do_softirq+0x55/0x90
[575879.073266]  [<ffffffff8103eb35>] irq_exit+0x75/0x90
[575879.075618]  [<ffffffff8101aeed>] smp_apic_timer_interrupt+0x6d/0xa0
[575879.094357]  [<ffffffff81003693>] apic_timer_interrupt+0x13/0x20
[575879.099195]  <EOI>  [<ffffffff8100b186>] ? mwait_idle+0x66/0x80
[575879.102225]  [<ffffffff81001f90>] ? enter_idle+0x20/0x30
[575879.119572]  [<ffffffff81002003>] cpu_idle+0x63/0xb0
[575879.121925]  [<ffffffff818ab5de>] start_secondary+0x158/0x1aa
[575879.125708] ---[ end trace d4f601a1b34bd328 ]---
[575879.130792] bnx2: eth0 DEBUG: intr_sem[0]
[575879.132880] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575879.149587] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575879.152959] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575883.951883] bnx2: eth0 DEBUG: intr_sem[0]
[575883.961580] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575883.974574] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575883.985269] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575888.951879] bnx2: eth0 DEBUG: intr_sem[0]
[575888.955092] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575888.967583] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575888.973761] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575893.951883] bnx2: eth0 DEBUG: intr_sem[0]
[575893.953954] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575893.964160] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575893.968596] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575898.951879] bnx2: eth0 DEBUG: intr_sem[0]
[575898.957913] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575898.962225] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575898.972121] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575903.951883] bnx2: eth0 DEBUG: intr_sem[0]
[575903.956728] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575903.961380] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575903.972171] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575908.951880] bnx2: eth0 DEBUG: intr_sem[0]
[575908.956790] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575908.961398] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575908.974628] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575913.951883] bnx2: eth0 DEBUG: intr_sem[0]
[575913.958417] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575913.962159] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575913.965457] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575918.951879] bnx2: eth0 DEBUG: intr_sem[0]
[575918.958634] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575918.965095] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575918.974149] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575923.951883] bnx2: eth0 DEBUG: intr_sem[0]
[575923.964361] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575923.970549] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575923.975969] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575928.951879] bnx2: eth0 DEBUG: intr_sem[0]
[575928.961375] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575928.965103] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575928.969552] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575933.951883] bnx2: eth0 DEBUG: intr_sem[0]
[575933.963067] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575933.970543] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575933.993032] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575938.951879] bnx2: eth0 DEBUG: intr_sem[0]
[575938.958134] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575938.961695] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575938.968855] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575943.951883] bnx2: eth0 DEBUG: intr_sem[0]
[575943.959389] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
[575943.964102] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
[575943.967612] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
[575948.951879] bnx2: eth0 DEBUG: intr_sem[0]
....

Blocked collectd task:
[576003.053144] INFO: task collectd:3019 blocked for more than 120 seconds.
[576003.066206] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[576003.072659] collectd      D 0000000000000000     0  3019      1 0x00020000
[576003.072663]  ffff8802aa3afa78 0000000000200086 0000000000000000 0000000000000008
[576003.072666]  0000000000012780 000000000000dda8 ffff8802aa3affd8 ffff8802aa256fa0
[576003.072670]  ffff8802af86e9c0 ffff8802aa257208 00000005ab1a3000 00000001036e43c3
[576003.072673] Call Trace:
[576003.072682]  [<ffffffff813ff33e>] __mutex_lock_slowpath+0x12e/0x180
[576003.072687]  [<ffffffff813fecfe>] mutex_lock+0x1e/0x40
[576003.072690]  [<ffffffff81357fd8>] rtnetlink_rcv+0x18/0x40
[576003.072694]  [<ffffffff813621b5>] netlink_unicast+0x285/0x290
[576003.072698]  [<ffffffff81344f83>] ? memcpy_fromiovec+0x63/0x80
[576003.072701]  [<ffffffff81362c63>] netlink_sendmsg+0x1d3/0x2c0
[576003.072705]  [<ffffffff810bdd9e>] ? __d_instantiate+0x5e/0xd0
[576003.072708]  [<ffffffff8133981b>] sock_sendmsg+0xbb/0xf0
[576003.072712]  [<ffffffff810c72aa>] ? seq_open+0x4a/0xa0
[576003.072714]  [<ffffffff81338ed9>] ? copy_from_user+0x9/0x10
[576003.072717]  [<ffffffff81338f0c>] ? move_addr_to_kernel+0x2c/0x40
[576003.072720]  [<ffffffff8135e09c>] ? verify_compat_iovec+0x9c/0x110
[576003.072723]  [<ffffffff8133b734>] sys_sendmsg+0x184/0x320
[576003.072728]  [<ffffffff810f5d60>] ? proc_delete_inode+0x0/0x50
[576003.072731]  [<ffffffff810700e0>] ? call_rcu_sched+0x10/0x20
[576003.072733]  [<ffffffff810700f9>] ? call_rcu+0x9/0x10
[576003.072736]  [<ffffffff810bca9a>] ? d_free+0x3a/0x60
[576003.072741]  [<ffffffff810acae8>] ? __fput+0x178/0x1f0
[576003.072744]  [<ffffffff81058014>] ? getnstimeofday+0x64/0xf0
[576003.072747]  [<ffffffff8135d94c>] compat_sys_socketcall+0xcc/0x210
[576003.072751]  [<ffffffff8102a1a4>] sysenter_dispatch+0x7/0x2b
