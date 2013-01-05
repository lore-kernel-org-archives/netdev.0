From: =?UTF-8?Q?J=C3=B6rg_Otte?= <jrg.otte@gmail.com>
Subject: [3.8-rc] regression: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0
 timed out
Date: Sat, 5 Jan 2013 10:01:42 +0100
Message-ID: <CADDKRnBqxSwC7HUP_aN1QELrv2+7jnncXj7EP0Pqv8E8FFTpPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I frequently see the following in the syslog:

[  184.552914] ------------[ cut here ]------------
[  184.552927] WARNING: at
/data/kernel/linux/net/sched/sch_generic.c:254
dev_watchdog+0xf2/0x151()
[  184.552929] Hardware name: LIFEBOOK AH532
[  184.552932] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed ou=
t
[  184.552937] Pid: 0, comm: swapper/1 Not tainted
3.8.0-rc2-b11-00221-gd1c3ed6 #15
[  184.552939] Call Trace:
[  184.552941]  <IRQ>  [<ffffffff8138d4a2>] ? dev_watchdog+0xf2/0x151
[  184.552953]  [<ffffffff81025c8a>] ? warn_slowpath_common+0x73/0x87
[  184.552956]  [<ffffffff8138d3b0>] ? netif_tx_unlock+0x49/0x49
[  184.552961]  [<ffffffff81025d02>] ? warn_slowpath_fmt+0x45/0x4a
[  184.552967]  [<ffffffff8138d332>] ? netif_tx_lock+0x40/0x75
[  184.552971]  [<ffffffff8138d4a2>] ? dev_watchdog+0xf2/0x151
[  184.552977]  [<ffffffff8102f1a1>] ? call_timer_fn.isra.32+0x1d/0x73
[  184.552981]  [<ffffffff8102f34b>] ? run_timer_softirq+0x154/0x194
[  184.552988]  [<ffffffff8104cb84>] ? timekeeping_get_ns.constprop.6+0=
xd/0x31
[  184.552992]  [<ffffffff8102b4a5>] ? __do_softirq+0x96/0x139
[  184.552997]  [<ffffffff8146b00c>] ? call_softirq+0x1c/0x26
[  184.553002]  [<ffffffff81003cf4>] ? do_softirq+0x2e/0x62
[  184.553006]  [<ffffffff8102b615>] ? irq_exit+0x3d/0x98
[  184.553011]  [<ffffffff810184ad>] ? smp_apic_timer_interrupt+0x73/0x=
80
[  184.553018]  [<ffffffff8146aa0a>] ? apic_timer_interrupt+0x6a/0x70
[  184.553020]  <EOI>  [<ffffffff81326f2b>] ? cpuidle_wrap_enter+0x38/0=
x69
[  184.553033]  [<ffffffff81326f27>] ? cpuidle_wrap_enter+0x34/0x69
[  184.553039]  [<ffffffff81326d81>] ? cpuidle_enter_state+0xa/0x31
[  184.553044]  [<ffffffff81326e41>] ? cpuidle_idle_call+0x99/0xb9
[  184.553050]  [<ffffffff81009059>] ? cpu_idle+0x99/0xe0
[  184.553056]  [<ffffffff8145e3a4>] ? start_secondary+0x1d6/0x1dc
[  184.553059] ---[ end trace 54db26a54b22f673 ]---
[  184.587487] r8169 0000:02:00.0 eth0: link up

It's a regression, it never happend before 3.8-rc.

-- J=C3=B6rg
