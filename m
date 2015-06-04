From: Stefan Hajnoczi <stefanha-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC 07/10] SUNRPC: restrict backchannel svc IPPROTO_TCP check to IP
Date: Thu,  4 Jun 2015 17:45:50 +0100
Message-ID: <1433436353-6761-8-git-send-email-stefanha@redhat.com>
References: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
Cc: Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	asias.hejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Berrange <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Stefan Hajnoczi <stefanha-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1433436353-6761-1-git-send-email-stefanha-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The IPPROTO_TCP check only applies to AF_INET and AF_INET6.

Signed-off-by: Stefan Hajnoczi <stefanha-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 net/sunrpc/svc.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 78974e4..1c9c5bc 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1365,9 +1365,16 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	/* reset result send buffer "put" position */
 	resv->iov_len = 0;
 
-	if (rqstp->rq_prot != IPPROTO_TCP) {
-		printk(KERN_ERR "No support for Non-TCP transports!\n");
-		BUG();
+	switch (((struct sockaddr *)&rqstp->rq_addr)->sa_family) {
+	case AF_INET:
+	case AF_INET6:
+		if (rqstp->rq_prot != IPPROTO_TCP) {
+			printk(KERN_ERR "No support for Non-TCP transports!\n");
+			BUG();
+		}
+		break;
+	default:
+		break;
 	}
 
 	/*
-- 
2.4.2

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
