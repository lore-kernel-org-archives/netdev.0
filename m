From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: "Close NETIF_F_LLTX race conditions" problem
Date: Sun, 23 Jan 2005 21:19:04 +0900
Message-ID: <871xcc5oef.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I got the following warning. The cause of this warning is the context
of ->hard_start_xmit() was changed. Before that patch the IRQ was
enableing, but now it was disabled.

With this change, the assumption of some drivers was changed, so now
some drivers need to change the ->hard_start_xmit().
(e.g, dev_kfree_skb() -> dev_kfree_skb_irq(), spin_lock_irq() -> spin_lock()).

Umm.. Should we fix the all drivers? Any idea?

Thanks.

Badness in local_bh_enable at kernel/softirq.c:140
 [<c0123139>] local_bh_enable+0x79/0x80
 [<e8a7872a>] svc_write_space+0x2a/0xa0 [sunrpc]
 [<c024e38a>] sock_wfree+0x4a/0x50
 [<c024f913>] __kfree_skb+0x63/0x140
 [<e899841c>] rtl8139_start_xmit+0x7c/0x160 [8139too]
 [<c0262c2d>] qdisc_restart+0x14d/0x1c0
 [<c02556ff>] dev_queue_xmit+0x1cf/0x270
 [<c026dffd>] ip_finish_output+0xcd/0x210
 [<c02950dd>] inet_sendmsg+0x4d/0x60
 [<c02701e4>] ip_push_pending_frames+0x2c4/0x460
 [<c028cd6c>] udp_push_pending_frames+0x16c/0x2b0
 [<c028d6ad>] udp_sendpage+0xdd/0x150
 [<c012d2a8>] set_current_groups+0x78/0x80
 [<c029518e>] inet_sendpage+0x9e/0xd0
 [<e8a78329>] svc_sendto+0xa9/0x2a0 [sunrpc]
 [<c024f8a4>] kfree_skbmem+0x24/0x30
 [<e8a78a5e>] svc_udp_sendto+0x1e/0x40 [sunrpc]
 [<e8a79d1b>] svc_send+0xcb/0x110 [sunrpc]
 [<e8a778e0>] svc_process+0x220/0x6b0 [sunrpc]
 [<c01193e0>] default_wake_function+0x0/0x20
 [<e8b4941b>] nfsd+0x1cb/0x350 [nfsd]
 [<e8b49250>] nfsd+0x0/0x350 [nfsd]
 [<c0101375>] kernel_thread_helper+0x5/0x10
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
