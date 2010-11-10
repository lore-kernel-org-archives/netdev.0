From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 9/9] net/sunrpc/svc.c: Use printf extension %pV
Date: Tue,  9 Nov 2010 16:35:23 -0800
Message-ID: <b604853e1e9ceb978763d7d798e45f234226feaa.1289348758.git.joe@perches.com>
References: <cover.1289348757.git.joe@perches.com>
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1289348757.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Using %pV reduces the number of printk calls and
eliminates any possible message interleaving from
other printk calls.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 net/sunrpc/svc.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6359c42..e28ddb3 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -962,6 +962,7 @@ static int
 __attribute__ ((format (printf, 2, 3)))
 svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 {
+	struct va_format vaf;
 	va_list args;
 	int 	r;
 	char 	buf[RPC_MAX_ADDRBUFLEN];
@@ -969,11 +970,14 @@ svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 	if (!net_ratelimit())
 		return 0;
 
-	printk(KERN_WARNING "svc: %s: ",
-		svc_print_addr(rqstp, buf, sizeof(buf)));
-
 	va_start(args, fmt);
-	r = vprintk(fmt, args);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	r = printk(KERN_WARNING "svc: %s: %pV",
+		   svc_print_addr(rqstp, buf, sizeof(buf)), &vaf);
+
 	va_end(args);
 
 	return r;
-- 
1.7.3.1.g432b3.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
