From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TCP crashes when cycling loopback interface.
Date: Thu, 07 Oct 2004 20:30:07 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CFVXD-0007iJ-00@gondolin.me.apana.org.au>
References: <Xine.LNX.4.44.0410070200270.2111-100000@thoron.boston.redhat.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@redhat.com (James Morris)
In-Reply-To: <Xine.LNX.4.44.0410070200270.2111-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Morris <jmorris@redhat.com> wrote:
> On an FC2 system, kernel 2.6.9-rc3-mm2 (selinux=0), running this causes a 
> often repeatable oopses:

Please apply the foolowing patch and see if it produces a meaningful
back trace.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== include/net/tcp.h 1.95 vs edited =====
--- 1.95/include/net/tcp.h	2004-10-04 07:31:39 +10:00
+++ edited/include/net/tcp.h	2004-10-07 20:28:08 +10:00
@@ -30,6 +30,7 @@
 #include <linux/slab.h>
 #include <linux/cache.h>
 #include <linux/percpu.h>
+#include <linux/kernel.h>
 #include <net/checksum.h>
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -1174,6 +1175,7 @@
 
 static inline void tcp_inc_pcount(tcp_pcount_t *count, struct sk_buff *skb)
 {
+	WARN_ON(tcp_skb_pcount(skb) == 0);
 	count->val += tcp_skb_pcount(skb);
 }
 
@@ -1189,12 +1191,14 @@
 
 static inline void tcp_dec_pcount(tcp_pcount_t *count, struct sk_buff *skb)
 {
+	WARN_ON(tcp_skb_pcount(skb) == 0);
 	count->val -= tcp_skb_pcount(skb);
 }
 
 static inline void tcp_dec_pcount_approx(tcp_pcount_t *count,
 					 struct sk_buff *skb)
 {
+	WARN_ON(tcp_skb_pcount(skb) == 0);
 	if (count->val) {
 		count->val -= tcp_skb_pcount(skb);
 		if ((int)count->val < 0)
