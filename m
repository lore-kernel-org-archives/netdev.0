From: Peter Palfrader <peter@palfrader.org>
Subject: 2.6.25.6: warn_on_slowpath in tcp_input.c
Date: Tue, 1 Jul 2008 01:09:54 +0200
Message-ID: <20080630230954.GS16698@anguilla.noreply.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anguilla.debian.or.at ([86.59.118.152]:48223 "EHLO
	anguilla.debian.or.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438AbYF3X3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 19:29:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

I found a couple of backtraces on one of our machines.  I didn't notice
anything weird on it other than that; it seems to be pushing its
constant 40 to 60 Mbps as always.

I've had 13 or so of them since upgrading the machine to a 2.6.25 kernel
20 days ago.

Linux saens 2.6.25.6-dl380 #2 SMP Tue Jun 10 17:54:44 CEST 2008 i686 GNU/Linux


Jun 30 04:08:50 saens kernel: [1659894.570682] ------------[ cut here ]------------
Jun 30 04:08:50 saens kernel: [1659894.570682] WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0x1b35/0x1d72()
Jun 30 04:08:50 saens kernel: [1659894.570682] Pid: 0, comm: swapper Not tainted 2.6.25.6-dl380 #2
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c0122f8d>] warn_on_slowpath+0x49/0x59
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c0149eb8>] ? __free_pages+0x27/0x29
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c0149ed9>] ? free_pages+0x1f/0x21
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c015fb06>] ? kmem_freepages+0x90/0xc4
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c015fd33>] ? slab_destroy+0x2f/0x47
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c015fe64>] ? free_block+0x119/0x12e
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c0284215>] ? memmove+0x28/0x2f
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c015fbb2>] ? cache_flusharray+0x78/0xb8
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c03b492a>] ? bictcp_cong_avoid+0x13/0x383
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c035a4bb>] ? skb_release_data+0x59/0x85
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c038d72b>] tcp_ack+0x1b35/0x1d72
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c0395824>] ? tcp_v4_send_synack+0x9d/0xf2
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c03907e6>] tcp_rcv_established+0x41d/0x8c7
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c0374d0d>] ? tcp_error+0xaa/0x1c0
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c0374c63>] ? tcp_error+0x0/0x1c0
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c03967ef>] tcp_v4_do_rcv+0x3cb/0x50a
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c03842d1>] ? __inet_lookup_established+0xc7/0x179
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c039852e>] tcp_v4_rcv+0x573/0x777
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c037d0de>] ip_local_deliver_finish+0x7b/0x1af
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c037d5a7>] ip_local_deliver+0x2d/0x96
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c037d063>] ? ip_local_deliver_finish+0x0/0x1af
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c037ce97>] ip_rcv_finish+0xc7/0x293
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c0370e2c>] ? nf_hook_slow+0x4a/0xb5
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c037cdd0>] ? ip_rcv_finish+0x0/0x293
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c037d4a0>] ip_rcv+0x197/0x271
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c037cdd0>] ? ip_rcv_finish+0x0/0x293
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c035f472>] netif_receive_skb+0x220/0x2ac
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c02f3e43>] e100_poll+0x140/0x45d
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c0136a37>] ? hrtimer_start+0xb4/0x137
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c03614a1>] net_rx_action+0x89/0x16d
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c0127a07>] __do_softirq+0x75/0xe6
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c0127ab3>] do_softirq+0x3b/0x3d
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c0127d25>] irq_exit+0x63/0x75
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c010565b>] do_IRQ+0x45/0x7a
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c01035df>] common_interrupt+0x23/0x28
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c013007b>] ? sys_setregid+0xa/0x107
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c01019bf>] ? default_idle+0x40/0x5f
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c010197f>] ? default_idle+0x0/0x5f
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c010189d>] cpu_idle+0x4f/0x8d
Jun 30 04:08:50 saens kernel: [1659894.570682]  [<c040b039>] rest_init+0x49/0x4b
Jun 30 04:08:50 saens kernel: [1659894.570682]  =======================
Jun 30 04:08:50 saens kernel: [1659894.570682] ---[ end trace 2b6550de0a1db34c ]---

Most are very similar, differences being these:

--- 1a  2008-07-01 00:54:56.514224160 +0200
+++ 2   2008-07-01 00:55:03.410219826 +0200
@@ -8,11 +8,12 @@
  [<c015fd33>] ? slab_destroy+0x2f/0x47
  [<c015fe64>] ? free_block+0x119/0x12e
  [<c0284215>] ? memmove+0x28/0x2f
+ [<c0284215>] ? memmove+0x28/0x2f
  [<c015fbb2>] ? cache_flusharray+0x78/0xb8
- [<c03b492a>] ? bictcp_cong_avoid+0x13/0x383
  [<c035a4bb>] ? skb_release_data+0x59/0x85
+ [<c038ac46>] ? tcp_enter_frto_loss+0x163/0x1d3
  [<c038d72b>] tcp_ack+0x1b35/0x1d72
- [<c0395824>] ? tcp_v4_send_synack+0x9d/0xf2
+ [<c012b47b>] ? lock_timer_base+0x1f/0x40
  [<c03907e6>] tcp_rcv_established+0x41d/0x8c7
  [<c0374d0d>] ? tcp_error+0xaa/0x1c0
  [<c0374c63>] ? tcp_error+0x0/0x1c0

or
--- 1a  2008-07-01 00:54:56.514224160 +0200
+++ 3   2008-07-01 00:55:35.554219380 +0200
@@ -8,11 +8,10 @@
  [<c015fd33>] ? slab_destroy+0x2f/0x47
  [<c015fe64>] ? free_block+0x119/0x12e
  [<c0284215>] ? memmove+0x28/0x2f
+ [<c0284215>] ? memmove+0x28/0x2f
  [<c015fbb2>] ? cache_flusharray+0x78/0xb8
- [<c03b492a>] ? bictcp_cong_avoid+0x13/0x383
- [<c035a4bb>] ? skb_release_data+0x59/0x85
+ [<c038ac46>] ? tcp_enter_frto_loss+0x163/0x1d3
  [<c038d72b>] tcp_ack+0x1b35/0x1d72
- [<c0395824>] ? tcp_v4_send_synack+0x9d/0xf2
  [<c03907e6>] tcp_rcv_established+0x41d/0x8c7
  [<c0374d0d>] ? tcp_error+0xaa/0x1c0
  [<c0374c63>] ? tcp_error+0x0/0x1c0



This one is different since it doesn't come via __free_pages but from
ip_finish_output:

------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0x1b35/0x1d72()
Pid: 0, comm: swapper Not tainted 2.6.25.6-dl380 #2
 [<c0122f8d>] warn_on_slowpath+0x49/0x59
 [<c0380c14>] ? ip_finish_output+0x0/0x281
 [<c038117b>] ? ip_output+0x5c/0x95
 [<c0380c14>] ? ip_finish_output+0x0/0x281
 [<c03808d3>] ? ip_local_out+0x18/0x1b
 [<c0284215>] ? memmove+0x28/0x2f
 [<c015fbb2>] ? cache_flusharray+0x78/0xb8
 [<c035a4bb>] ? skb_release_data+0x59/0x85
 [<c038ac46>] ? tcp_enter_frto_loss+0x163/0x1d3
 [<c038d72b>] tcp_ack+0x1b35/0x1d72
 [<c041a7ed>] ? _spin_unlock_bh+0xd/0xf
 [<c03752b9>] ? tcp_packet+0x496/0xb3d
 [<c038fd57>] tcp_rcv_state_process+0x40d/0xa7f
 [<c041a7de>] ? _read_unlock_bh+0xe/0x10
 [<c0396540>] tcp_v4_do_rcv+0x11c/0x50a
 [<c03842d1>] ? __inet_lookup_established+0xc7/0x179
 [<c039852e>] tcp_v4_rcv+0x573/0x777
 [<c037d0de>] ip_local_deliver_finish+0x7b/0x1af
 [<c037d5a7>] ip_local_deliver+0x2d/0x96
 [<c037d063>] ? ip_local_deliver_finish+0x0/0x1af
 [<c037ce97>] ip_rcv_finish+0xc7/0x293
 [<c0370e2c>] ? nf_hook_slow+0x4a/0xb5
 [<c037cdd0>] ? ip_rcv_finish+0x0/0x293
 [<c037d4a0>] ip_rcv+0x197/0x271
 [<c037cdd0>] ? ip_rcv_finish+0x0/0x293
 [<c035f472>] netif_receive_skb+0x220/0x2ac
 [<c02f3e43>] e100_poll+0x140/0x45d
 [<c0136a37>] ? hrtimer_start+0xb4/0x137
 [<c03614a1>] net_rx_action+0x89/0x16d
 [<c0127a07>] __do_softirq+0x75/0xe6
 [<c0127ab3>] do_softirq+0x3b/0x3d
 [<c0127d25>] irq_exit+0x63/0x75
 [<c010565b>] do_IRQ+0x45/0x7a
 [<c0127d17>] ? irq_exit+0x55/0x75
 [<c010f0b2>] ? smp_apic_timer_interrupt+0x5d/0x8b
 [<c01035df>] common_interrupt+0x23/0x28
 [<c013007b>] ? sys_setregid+0xa/0x107
 [<c01019bf>] ? default_idle+0x40/0x5f
 [<c010197f>] ? default_idle+0x0/0x5f
 [<c010189d>] cpu_idle+0x4f/0x8d
 [<c040b039>] rest_init+0x49/0x4b
 =======================
---[ end trace 2b6550de0a1db34c ]---

another variation of that is

------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0x1b35/0x1d72()
Pid: 0, comm: swapper Not tainted 2.6.25.6-dl380 #2
 [<c0122f8d>] warn_on_slowpath+0x49/0x59
 [<c0380d49>] ? ip_finish_output+0x135/0x281
 [<c0380c14>] ? ip_finish_output+0x0/0x281
 [<c0284215>] ? memmove+0x28/0x2f
 [<c015fbb2>] ? cache_flusharray+0x78/0xb8
 [<c012b47b>] ? lock_timer_base+0x1f/0x40
 [<c039112d>] ? tcp_snd_test+0x15/0xea
 [<c0391242>] ? tcp_may_send_now+0x40/0x59
 [<c038d72b>] tcp_ack+0x1b35/0x1d72
 [<c03907e6>] tcp_rcv_established+0x41d/0x8c7
 [<c0374d0d>] ? tcp_error+0xaa/0x1c0
 [<c0374c63>] ? tcp_error+0x0/0x1c0
 [<c03967ef>] tcp_v4_do_rcv+0x3cb/0x50a
 [<c03842d1>] ? __inet_lookup_established+0xc7/0x179
 [<c039852e>] tcp_v4_rcv+0x573/0x777
 [<c037d0de>] ip_local_deliver_finish+0x7b/0x1af
 [<c037d5a7>] ip_local_deliver+0x2d/0x96
 [<c037d063>] ? ip_local_deliver_finish+0x0/0x1af
 [<c037ce97>] ip_rcv_finish+0xc7/0x293
 [<c0370e2c>] ? nf_hook_slow+0x4a/0xb5
 [<c037cdd0>] ? ip_rcv_finish+0x0/0x293
 [<c037d4a0>] ip_rcv+0x197/0x271
 [<c037cdd0>] ? ip_rcv_finish+0x0/0x293
 [<c035f472>] netif_receive_skb+0x220/0x2ac
 [<c02f3e43>] e100_poll+0x140/0x45d
 [<c013b458>] ? clockevents_program_event+0xae/0x104
 [<c03614a1>] net_rx_action+0x89/0x16d
 [<c0127a07>] __do_softirq+0x75/0xe6
 [<c0127ab3>] do_softirq+0x3b/0x3d
 [<c0127d25>] irq_exit+0x63/0x75
 [<c010565b>] do_IRQ+0x45/0x7a
 [<c01035df>] common_interrupt+0x23/0x28
 [<c013007b>] ? sys_setregid+0xa/0x107
 [<c01019bf>] ? default_idle+0x40/0x5f
 [<c010197f>] ? default_idle+0x0/0x5f
 [<c010189d>] cpu_idle+0x4f/0x8d
 [<c040b039>] rest_init+0x49/0x4b
 =======================
---[ end trace 2b6550de0a1db34c ]---



If you need to know anything else please let me know.  Please CC me on
replies,

Peter
-- 
                           |  .''`.  ** Debian GNU/Linux **
      Peter Palfrader      | : :' :      The  universal
 http://www.palfrader.org/ | `. `'      Operating System
                           |   `-    http://www.debian.org/
