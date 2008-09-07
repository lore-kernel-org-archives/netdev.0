From: Bernard Pidoux <bernard.pidoux@upmc.fr>
Subject: [ INFO: inconsistent lock state ]  2.6.25.10
Date: Sun, 07 Sep 2008 14:53:52 +0200
Message-ID: <48C3CEE0.6040308@upmc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g19.free.fr ([212.27.42.30]:46417 "EHLO smtp4-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753127AbYIGMx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Sep 2008 08:53:56 -0400
Received: from smtp4-g19.free.fr (localhost.localdomain [127.0.0.1])
	by smtp4-g19.free.fr (Postfix) with ESMTP id 3DBDA3EA0BB
	for <netdev@vger.kernel.org>; Sun,  7 Sep 2008 14:53:54 +0200 (CEST)
Received: from [192.168.0.66] (car75-2-82-66-61-83.fbx.proxad.net [82.66.61.83])
	by smtp4-g19.free.fr (Postfix) with ESMTP id DA9E53EA124
	for <netdev@vger.kernel.org>; Sun,  7 Sep 2008 14:53:53 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I observed this message recently on a system with acpi=off for
the bios is quite old.

Apparently listen application and console are involved.

Is there anything I can try to resolve this situation ,


=================================
[ INFO: inconsistent lock state ]
2.6.25.10-patched-ax25 #1
---------------------------------
inconsistent {in-softirq-W} -> {softirq-on-W} usage.
listen/7202 [HC0[0]:SC0[0]:HE1:SE1] takes:
  (_xmit_ETHER){-+..}, at: [<c0262f08>] netpoll_send_skb+0x118/0x180
{in-softirq-W} state was registered at:
   [<c013af92>] __lock_acquire+0x3c2/0x1100
   [<c013bd50>] lock_acquire+0x80/0xa0
   [<c02beac3>] _spin_lock+0x33/0x60
   [<c0265c30>] __qdisc_run+0x130/0x1b0
   [<c025815c>] dev_queue_xmit+0x25c/0x330
   [<c8c4955f>] mld_sendpack+0x2cf/0x2f0 [ipv6]
   [<c8c4a6e5>] mld_ifc_timer_expire+0x175/0x260 [ipv6]
   [<c0122d19>] run_timer_softirq+0x149/0x1b0
   [<c011f054>] __do_softirq+0x54/0xc0
   [<c011f107>] do_softirq+0x47/0x50
   [<c011f557>] irq_exit+0x57/0x70
   [<c01062df>] do_IRQ+0x4f/0xa0
   [<c0104672>] common_interrupt+0x2e/0x34
   [<ffffffff>] 0xffffffff
irq event stamp: 8625
hardirqs last  enabled at (8625): [<c02bf0e7>] 
_spin_unlock_irqrestore+0x47/0x60
hardirqs last disabled at (8624): [<c02bef69>] _spin_lock_irqsave+0x19/0x70
softirqs last  enabled at (8620): [<c011f0a3>] __do_softirq+0xa3/0xc0
softirqs last disabled at (8579): [<c011f107>] do_softirq+0x47/0x50

other info that might help us debug this:
2 locks held by listen/7202:
  #0:  (&tty->atomic_write_lock){--..}, at: [<c020abac>] 
tty_write_lock+0x1c/0x50
  #1:  (target_list_lock){--..}, at: [<c8abd10d>] write_msg+0x2d/0xe0 
[netconsole]

stack backtrace:
Pid: 7202, comm: listen Not tainted 2.6.25.10-patched-ax25 #1
  [<c0139226>] print_usage_bug+0x156/0x160
  [<c013a390>] mark_lock+0x400/0x5a0
  [<c0108327>] ? native_sched_clock+0x77/0xb0
  [<c013afd8>] __lock_acquire+0x408/0x1100
  [<c013a70d>] ? trace_hardirqs_on+0xbd/0x140
  [<c024f4e3>] ? skb_dequeue+0x43/0x60
  [<c013bd50>] lock_acquire+0x80/0xa0
  [<c0262f08>] ? netpoll_send_skb+0x118/0x180
  [<c02be81a>] __lock_text_start+0x3a/0x50
  [<c0262f08>] ? netpoll_send_skb+0x118/0x180
  [<c0262f08>] netpoll_send_skb+0x118/0x180
  [<c0263c97>] netpoll_send_udp+0x217/0x290
  [<c8abd17c>] write_msg+0x9c/0xe0 [netconsole]
  [<c8abd0e0>] ? write_msg+0x0/0xe0 [netconsole]
  [<c011a4a7>] __call_console_drivers+0x47/0x60
  [<c011a539>] _call_console_drivers+0x79/0x90
  [<c011a913>] release_console_sem+0xd3/0x1f0
  [<c0219181>] do_con_write+0x161/0x1a20
  [<c013a500>] ? mark_lock+0x570/0x5a0
  [<c02bf0e7>] ? _spin_unlock_irqrestore+0x47/0x60
  [<c011aa04>] ? release_console_sem+0x1c4/0x1f0
  [<c021aa84>] con_write+0x14/0x30
  [<c020d5d2>] write_chan+0x192/0x340
  [<c0115f40>] ? default_wake_function+0x0/0x10
  [<c020ad75>] tty_write+0x125/0x1b0
  [<c020d440>] ? write_chan+0x0/0x340
  [<c0175515>] vfs_write+0x95/0x120
  [<c020ac50>] ? tty_write+0x0/0x1b0
  [<c0175a6d>] sys_write+0x3d/0x70
  [<c0103bda>] sysenter_past_esp+0x5f/0xa5
  =======================
