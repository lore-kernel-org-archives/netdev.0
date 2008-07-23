From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: more atl1 vs multiqueue TX
Date: Wed, 23 Jul 2008 09:58:23 +0400
Message-ID: <20080723055823.GA4803@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jacliburn@bellsouth.net, csnook@redhat.com,
	jeff@garzik.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:23072 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbYGWF7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 01:59:10 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1044075fgg.17
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 22:59:09 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now if I normally boot with cable unplugged, and then plug it,
bug/warning triggers, always the same:

eth1: link up, 100Mbps, full-duplex, lpa 0x45E1
atl1 0000:03:00.0: eth0 link is up 1000 Mbps full duplex
------------[ cut here ]------------
WARNING: at net/core/dev.c:1344 __netif_schedule+0xbd/0xd0()
Modules linked in: ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 xt_state iptable_filter iptable_raw ip_tables x_tables nf_conntrack_irc nf_conntrack fuse usblp ehci_hcd uhci_hcd usbcore sr_mod cdrom
Pid: 9, comm: events/0 Not tainted 2.6.26-c010b2f76c3032e48097a6eef291d8593d5d79a6 #1

Call Trace:
 <IRQ>  [<ffffffff8022f21f>] warn_on_slowpath+0x5f/0x80
 [<ffffffff80254616>] ? __lock_acquire+0x816/0xe50
 [<ffffffff8025135d>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff80463932>] ? _spin_unlock_irqrestore+0x42/0x80
 [<ffffffff804028dd>] __netif_schedule+0xbd/0xd0
 [<ffffffff803720ea>] atl1_intr+0x62a/0xc30
 [<ffffffff80254616>] ? __lock_acquire+0x816/0xe50
 [<ffffffff8025ec55>] handle_IRQ_event+0x35/0x70
 [<ffffffff8026061e>] handle_edge_irq+0xce/0x150
 [<ffffffff8020f1cf>] do_IRQ+0xaf/0x140
 [<ffffffff80370f90>] ? atlx_link_chg_task+0x0/0x60
 [<ffffffff8020bbf6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80239b39>] ? __mod_timer+0x99/0x110
 [<ffffffff80463958>] ? _spin_unlock_irqrestore+0x68/0x80
 [<ffffffff80370fd3>] ? atlx_link_chg_task+0x43/0x60
 [<ffffffff802414bd>] ? run_workqueue+0x18d/0x240
 [<ffffffff80241703>] ? worker_thread+0x93/0xd0
 [<ffffffff802457e0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80241670>] ? worker_thread+0x0/0xd0
 [<ffffffff8024531d>] ? kthread+0x4d/0x80
 [<ffffffff8020c699>] ? child_rip+0xa/0x11
 [<ffffffff8020bca3>] ? restore_args+0x0/0x30
 [<ffffffff80245476>] ? kthreadd+0x126/0x1b0
 [<ffffffff802452d0>] ? kthread+0x0/0x80
 [<ffffffff8020c68f>] ? child_rip+0x0/0x11

netconsole is in use, straight from the start.

After plugging cable, network is fine.

