From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [BUG]? xfrm: INFO: inconsistent lock state
Date: Mon, 01 Feb 2010 18:01:20 +0800
Message-ID: <4B66A670.70503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57415 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751764Ab0BAJ7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 04:59:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got following lock INFO in my Fedora12 box uner 2.6.33-rc6.
Is this a BUG?
 
=================================
[ INFO: inconsistent lock state ]
2.6.33-rc6 #120
---------------------------------
inconsistent {IN-HARDIRQ-W} -> {HARDIRQ-ON-W} usage.
swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
 (&(&x->lock)->rlock){?.-...}, at: [<c072d03f>] xfrm_input+0xdf/0x5c0
{IN-HARDIRQ-W} state was registered at:
  [<c04718dc>] __lock_acquire+0xa9c/0x1890
  [<c047274f>] lock_acquire+0x7f/0xf0
  [<c0762958>] _raw_spin_lock+0x38/0x50
  [<c072b5ca>] xfrm_timer_handler+0x3a/0x260
  [<c0447d9d>] __hrtimer_tasklet_trampoline+0xd/0x10
  [<c04634ce>] hrtimer_run_queues+0x15e/0x2a0
  [<c045146d>] run_local_timers+0xd/0x20
  [<c04514b4>] update_process_times+0x34/0x70
  [<c046ce8a>] tick_periodic+0x2a/0x80
  [<c046cefe>] tick_handle_periodic+0x1e/0x90
  [<c0768377>] smp_apic_timer_interrupt+0x57/0x8b
  [<c076382f>] apic_timer_interrupt+0x2f/0x34
  [<c0401d3b>] cpu_idle+0x4b/0x80
  [<c074e0d7>] rest_init+0x67/0x70
  [<c0956874>] start_kernel+0x30e/0x314
  [<c095609e>] i386_start_kernel+0x9e/0xa5
irq event stamp: 1113374
hardirqs last  enabled at (1113374): [<c0449288>] local_bh_enable_ip+0x68/0xd0
hardirqs last disabled at (1113373): [<c0449248>] local_bh_enable_ip+0x28/0xd0
softirqs last  enabled at (1113338): [<c0449570>] __do_softirq+0x100/0x1c0
softirqs last disabled at (1113343): [<c0404e17>] do_softirq+0x97/0xe0

other info that might help us debug this:
3 locks held by swapper/0:
 #0:  (rcu_read_lock){.+.+..}, at: [<c06b8426>] net_rx_action+0xd6/0x230
 #1:  (rcu_read_lock){.+.+..}, at: [<c06b77c8>] netif_receive_skb+0x138/0x570
 #2:  (rcu_read_lock){.+.+..}, at: [<d1c5d540>] ip6_input_finish+0x0/0x390 [ipv6]

stack backtrace:
Pid: 0, comm: swapper Not tainted 2.6.33-rc6 #120
Call Trace:
 [<c075f984>] ? printk+0x1d/0x21
 [<c046fb8f>] print_usage_bug+0x15f/0x1a0
 [<c046ff8a>] mark_lock+0x3ba/0x5c0
 [<c04701f2>] ? mark_held_locks+0x62/0x90
 [<c0473540>] ? check_usage_backwards+0x0/0xd0
 [<c04717ef>] __lock_acquire+0x9af/0x1890
 [<c05a0cac>] ? trace_hardirqs_on_thunk+0xc/0x10
 [<c07633fc>] ? restore_all_notrace+0x0/0x18
 [<c04701f2>] ? mark_held_locks+0x62/0x90
 [<c047274f>] lock_acquire+0x7f/0xf0
 [<c072d03f>] ? xfrm_input+0xdf/0x5c0
 [<c0762958>] _raw_spin_lock+0x38/0x50
 [<c072d03f>] ? xfrm_input+0xdf/0x5c0
 [<c072d03f>] xfrm_input+0xdf/0x5c0
 [<d1c88929>] xfrm6_rcv_spi+0x29/0x30 [ipv6]
 [<d1c8894c>] xfrm6_rcv+0x1c/0x20 [ipv6]
 [<d1c5d681>] ip6_input_finish+0x141/0x390 [ipv6]
 [<d1c5d540>] ? ip6_input_finish+0x0/0x390 [ipv6]
 [<d1c5d92f>] ip6_input+0x5f/0x70 [ipv6]
 [<d1c5de78>] ipv6_rcv+0x338/0x440 [ipv6]
 [<d1c5db6e>] ? ipv6_rcv+0x2e/0x440 [ipv6]
 [<c06b79df>] netif_receive_skb+0x34f/0x570
 [<c06b77c8>] ? netif_receive_skb+0x138/0x570
 [<c06affde>] ? __alloc_skb+0x4e/0x130
 [<c04080b0>] ? nommu_sync_single_for_device+0x0/0x10
 [<d087ec5e>] pcnet32_poll+0x27e/0x7a0 [pcnet32]
 [<c0450797>] ? run_timer_softirq+0x37/0x2c0
 [<c0763067>] ? _raw_spin_unlock_irq+0x27/0x30
 [<c06b84a0>] net_rx_action+0x150/0x230
 [<c06b8426>] ? net_rx_action+0xd6/0x230
 [<c04494c8>] ? __do_softirq+0x58/0x1c0
 [<c0449510>] __do_softirq+0xa0/0x1c0
 [<c0449470>] ? __do_softirq+0x0/0x1c0
 <IRQ>  [<c0448ce5>] ? irq_exit+0x45/0x50
 [<c076837c>] ? smp_apic_timer_interrupt+0x5c/0x8b
 [<c05a0cbc>] ? trace_hardirqs_off_thunk+0xc/0x10
 [<c076382f>] ? apic_timer_interrupt+0x2f/0x34
 [<c0409de3>] ? default_idle+0x43/0xa0
 [<c0401d3b>] ? cpu_idle+0x4b/0x80
 [<c074e0d7>] ? rest_init+0x67/0x70
 [<c0956874>] ? start_kernel+0x30e/0x314
 [<c0956390>] ? unknown_bootoption+0x0/0x1a0
 [<c095609e>] ? i386_start_kernel+0x9e/0xa5


