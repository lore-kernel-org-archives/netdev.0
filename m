From: Luis Henriques <luis.henriques-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] gss_krb5: use lcm from kernel lib
Date: Sun, 19 Jan 2014 21:50:51 +0000
Message-ID: <20140119215040.GA7978@hercules>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Replace hardcoded lowest common multiple algorithm by the lcm()
function in kernel lib.

Signed-off-by: Luis Henriques <luis.henriques-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 net/sunrpc/auth_gss/gss_krb5_keys.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
index 76e42e6..a16c5b6 100644
--- a/net/sunrpc/auth_gss/gss_krb5_keys.c
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -59,6 +59,7 @@
 #include <linux/crypto.h>
 #include <linux/sunrpc/gss_krb5.h>
 #include <linux/sunrpc/xdr.h>
+#include <linux/lcm.h>
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY        RPCDBG_AUTH
@@ -72,7 +73,7 @@
 static void krb5_nfold(u32 inbits, const u8 *in,
 		       u32 outbits, u8 *out)
 {
-	int a, b, c, lcm;
+	unsigned long ulcm;
 	int byte, i, msbit;
 
 	/* the code below is more readable if I make these bytes
@@ -82,17 +83,7 @@ static void krb5_nfold(u32 inbits, const u8 *in,
 	outbits >>= 3;
 
 	/* first compute lcm(n,k) */
-
-	a = outbits;
-	b = inbits;
-
-	while (b != 0) {
-		c = b;
-		b = a%b;
-		a = c;
-	}
-
-	lcm = outbits*inbits/a;
+	ulcm = lcm(inbits, outbits);
 
 	/* now do the real work */
 
@@ -101,7 +92,7 @@ static void krb5_nfold(u32 inbits, const u8 *in,
 
 	/* this will end up cycling through k lcm(k,n)/k times, which
 	   is correct */
-	for (i = lcm-1; i >= 0; i--) {
+	for (i = ulcm-1; i >= 0; i--) {
 		/* compute the msbit in k which gets added into this byte */
 		msbit = (
 			/* first, start with the msbit in the first,
-- 
1.8.3.2

Cheers,
--
Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
