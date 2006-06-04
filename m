From: James Morris <jmorris@namei.org>
Subject: icmp or table->lock deadlock bug? (lockdep) (fwd)
Date: Sun, 4 Jun 2006 00:09:23 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606040009180.5652@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:6098 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932175AbWFDEJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 00:09:26 -0400
Received: from megaweapon.nightmoose.net (HELO d.namei) ([66.92.66.197])
          (envelope-sender <jmorris@namei.org>)
          by mail7.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 4 Jun 2006 04:09:25 -0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---------- Forwarded message ----------
Date: Fri, 2 Jun 2006 16:31:44 -0700 (PDT)
From: Matthew L Foster <mfoster167@yahoo.com>
To: linux-kernel@vger.kernel.org
Cc: mfoster167@yahoo.com
Subject: icmp or table->lock deadlock bug? (lockdep)


Perhaps someone has hit this one already but in case not: 

====================================
[ BUG: possible deadlock detected! ]
------------------------------------
kicker/2665 is trying to acquire lock:
 (&table->lock){-.-+}, at: [<c02b1384>] ipt_do_table+0x68/0x294

but task is already holding lock:
 (&table->lock){-.-+}, at: [<c02b1384>] ipt_do_table+0x68/0x294

which could potentially lead to deadlocks!

other info that might help us debug this:
2 locks held by kicker/2665:
 #0:  (&table->lock){-.-+}, at: [<c02b1384>] ipt_do_table+0x68/0x294
 #1:  (&sk->sk_lock.slock#3){-+..}, at: [<c029dab8>] icmp_send+0x100/0x332

stack backtrace:
 <c01030b8> show_trace+0x16/0x19  <c0103586> dump_stack+0x1a/0x1f
 <c012a880> __lockdep_acquire+0x6c6/0x907  <c012addb> lockdep_acquire+0x4b/0x63
 <c02cdab1> _read_lock_bh+0x27/0x2f  <c02b1384> ipt_do_table+0x68/0x294
 <c02b1e37> ipt_hook+0x1b/0x20  <c0279606> nf_iterate+0x26/0x5a
 <c02798ab> nf_hook_slow+0x41/0xba  <c0282888> ip_push_pending_frames+0x2e2/0x3a9
 <c029d39d> icmp_push_reply+0xc2/0xcd  <c029dc8b> icmp_send+0x2d3/0x332
 <c02b371c> reject+0x49/0x551  <c02b155d> ipt_do_table+0x241/0x294
 <c02b162b> ipt_hook+0x1b/0x20  <c0279606> nf_iterate+0x26/0x5a
 <c02798ab> nf_hook_slow+0x41/0xba  <c0280482> ip_local_deliver+0x58/0x1e6
 <c02803fd> ip_rcv+0x3d5/0x402  <c026bc9b> netif_receive_skb+0x13d/0x1a4
 <c026d552> process_backlog+0x7c/0x112  <c026d35c> net_rx_action+0x5b/0xed
 <c01188ca> __do_softirq+0x45/0x9f  <c0104428> do_softirq+0x45/0xa4
 =======================
 <c0118954> irq_exit+0x30/0x3c  <c01044f7> do_IRQ+0x70/0x7d
 <c0102b45> common_interrupt+0x25/0x2c 


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
