From: Bernard Pidoux <bpidoux@free.fr>
Subject: inconsistent lock state with kernel 2.6.24.4
Date: Tue, 15 Apr 2008 22:14:43 +0200
Message-ID: <48050CB3.4040505@free.fr>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804150145.05571.tomasz@grobelny.oswiecenia.net> <20080415151403.GA20735@gerrit.erg.abdn.ac.uk> <200804152138.41077.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:50121 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146AbYDOUOs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 16:14:48 -0400
Received: from smtp5-g19.free.fr (localhost.localdomain [127.0.0.1])
	by smtp5-g19.free.fr (Postfix) with ESMTP id 1FC963F6352
	for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 22:14:46 +0200 (CEST)
Received: from [192.168.0.66] (car75-2-82-66-61-83.fbx.proxad.net [82.66.61.83])
	by smtp5-g19.free.fr (Postfix) with ESMTP id 2A8563F632B
	for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 22:14:45 +0200 (CEST)
In-Reply-To: <200804152138.41077.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here is an inconsistent lock state detected with 2.6.24.4 kernel.
I am not sure if it should be reported here or to kernel list ?


=================================
[ INFO: inconsistent lock state ]
2.6.24.4 #7
---------------------------------
inconsistent {in-softirq-W} -> {softirq-on-W} usage.
listen/3831 [HC0[0]:SC0[0]:HE1:SE1] takes:
  (_xmit_ETHER){-+..}, at: [<c0262cf6>] netpoll_send_skb+0x116/0x170
{in-softirq-W} state was registered at:
   [<c0139992>] __lock_acquire+0x402/0x11d0
   [<c013a7e3>] lock_acquire+0x83/0xa0
   [<c02badc3>] _spin_lock+0x33/0x60
   [<c0265988>] __qdisc_run+0x128/0x1a0
   [<c0257c6c>] dev_queue_xmit+0x25c/0x330
   [<c8c24a5f>] mld_sendpack+0x2cf/0x2f0 [ipv6]
   [<c8c25beb>] mld_ifc_timer_expire+0x17b/0x260 [ipv6]
   [<c0120f69>] run_timer_softirq+0x149/0x1b0
   [<c011d5c5>] __do_softirq+0x55/0xc0
   [<c011d677>] do_softirq+0x47/0x50
   [<c011dadc>] irq_exit+0x6c/0x80
   [<c010663f>] do_IRQ+0x4f/0xa0
   [<c0104bc2>] common_interrupt+0x2e/0x34
   [<ffffffff>] 0xffffffff
irq event stamp: 6133329
hardirqs last  enabled at (6133329): [<c02bb3e7>] 
_spin_unlock_irqrestore+0x47/0
x60
hardirqs last disabled at (6133328): [<c02bb269>] 
_spin_lock_irqsave+0x19/0x70
softirqs last  enabled at (6133322): [<c011d613>] __do_softirq+0xa3/0xc0
softirqs last disabled at (6133291): [<c011d677>] do_softirq+0x47/0x50

other info that might help us debug this:
2 locks held by listen/3831:
  #0:  (&tty->atomic_write_lock){--..}, at: [<c0208b5c>] 
tty_write_lock+0x1c/0x50
  #1:  (target_list_lock){--..}, at: [<c8abe10d>] write_msg+0x2d/0xf0 
[netconsole
]

stack backtrace:
Pid: 3831, comm: listen Not tainted 2.6.24.4 #7
  [<c010513a>] show_trace_log_lvl+0x1a/0x30
  [<c0105b52>] show_trace+0x12/0x20
  [<c01064ac>] dump_stack+0x6c/0x80
  [<c01379c6>] print_usage_bug+0x156/0x160
  [<c0138ceb>] mark_lock+0x49b/0x630
  [<c01399d8>] __lock_acquire+0x448/0x11d0
  [<c013a7e3>] lock_acquire+0x83/0xa0
  [<c02bab1a>] __lock_text_start+0x3a/0x50
  [<c0262cf6>] netpoll_send_skb+0x116/0x170
  [<c0263a7c>] netpoll_send_udp+0x20c/0x280
  [<c8abe18c>] write_msg+0xac/0xf0 [netconsole]
  [<c01187f7>] __call_console_drivers+0x47/0x60
  [<c0118889>] _call_console_drivers+0x79/0x90
  [<c0118c27>] release_console_sem+0xd7/0x1f0
  [<c02173c1>] do_con_write+0x161/0x1a20
  [<c0218cc4>] con_write+0x14/0x30
  [<c020b5c3>] write_chan+0x183/0x330
  [<c0208d26>] tty_write+0x126/0x1b0
  [<c017298f>] vfs_write+0xaf/0x120
  [<c0172edd>] sys_write+0x3d/0x70
  [<c010412a>] sysenter_past_esp+0x5f/0xa5
  =======================
Clocksource tsc unstable (delta = 88012255 ns)
Time: pit clocksource has been installed.


Bernard Pidoux
