From: Dave Jones <davej@redhat.com>
Subject: WARNING: at net/ipv4/tcp.c:1598 tcp_recvmsg+0x641/0xd30()
Date: Mon, 6 Aug 2012 11:46:16 -0400
Message-ID: <20120806154616.GB2187@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fedora Kernel Team <kernel-team@fedoraproject.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756442Ab2HFPqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 11:46:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We just got an automated report of this WARN being hit in 3.5

 > backtrace:
 > :WARNING: at net/ipv4/tcp.c:1598 tcp_recvmsg+0x641/0xd30()
 > :Hardware name: P5Q DELUXE
 > :recvmsg bug: copied 99F66400 seq 99F6A4A8 rcvnxt 99F6CDAD fl 0
 > : [<ffffffff811848e6>] do_sync_read+0xe6/0x120
 > : [<ffffffff81275eea>] ? inode_has_perm.isra.31.constprop.61+0x2a/0x30
 > : [<ffffffff81272f32>] ? security_file_permission+0x92/0xb0
 > : [<ffffffff81184d81>] ? rw_verify_area+0x61/0xf0
 > : [<ffffffff811852cd>] vfs_read+0x15d/0x180
 > : [<ffffffff8118533a>] sys_read+0x4a/0x90
 > : [<ffffffff8160fc29>] system_call_fastpath+0x16/0x1b

1594                         /* Now that we have two receive queues this
1595                          * shouldn't happen.
1596                          */
1597                         if (WARN(before(*seq, TCP_SKB_CB(skb)->seq),
1598                                  "recvmsg bug: copied %X seq %X rcvnxt %X fl %X\n",
1599                                  *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt,
1600                                  flags))
1601                                 break;


Hopefully this means more to you guys than it does to me.

	Dave
