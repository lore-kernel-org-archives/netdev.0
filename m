From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH 3/6] net: Remove unneeded kmalloc() return value casts
Date: Sun, 11 Dec 2005 20:34:20 +0100
Message-ID: <200512112034.20644.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Maxim Krasnyansky <maxk@qualcomm.com>,
	Olaf Kirch <okir@monad.swb.de>, netdev@vger.kernel.org,
	davem@davemloft.net, yoshfuji@linux-ipv6.org,
	Andrew Morton <akpm@osdl.org>,
	Jesper Juhl <jesper.juhl@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750821AbVLKTdt@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Get rid of needless casting of kmalloc() return value in net/


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 net/bluetooth/hci_conn.c |    2 +-
 net/sunrpc/svc.c         |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.15-rc5-git1-orig/net/bluetooth/hci_conn.c	2005-10-28 02:02:08.000000000 +0200
+++ linux-2.6.15-rc5-git1/net/bluetooth/hci_conn.c	2005-12-11 19:50:32.000000000 +0100
@@ -403,7 +403,7 @@ int hci_get_conn_list(void __user *arg)
 
 	size = sizeof(req) + req.conn_num * sizeof(*ci);
 
-	if (!(cl = (void *) kmalloc(size, GFP_KERNEL)))
+	if (!(cl = kmalloc(size, GFP_KERNEL)))
 		return -ENOMEM;
 
 	if (!(hdev = hci_dev_get(req.dev_id))) {
--- linux-2.6.15-rc5-git1-orig/net/sunrpc/svc.c	2005-12-04 18:49:00.000000000 +0100
+++ linux-2.6.15-rc5-git1/net/sunrpc/svc.c	2005-12-11 19:54:05.000000000 +0100
@@ -167,8 +167,8 @@ svc_create_thread(svc_thread_fn func, st
 	memset(rqstp, 0, sizeof(*rqstp));
 	init_waitqueue_head(&rqstp->rq_wait);
 
-	if (!(rqstp->rq_argp = (u32 *) kmalloc(serv->sv_xdrsize, GFP_KERNEL))
-	 || !(rqstp->rq_resp = (u32 *) kmalloc(serv->sv_xdrsize, GFP_KERNEL))
+	if (!(rqstp->rq_argp = kmalloc(serv->sv_xdrsize, GFP_KERNEL))
+	 || !(rqstp->rq_resp = kmalloc(serv->sv_xdrsize, GFP_KERNEL))
 	 || !svc_init_buffer(rqstp, serv->sv_bufsz))
 		goto out_thread;
 
