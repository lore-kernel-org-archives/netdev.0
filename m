From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPv4] Missing TOS checks after fib_find_alias
Date: Thu, 23 Sep 2004 16:28:31 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923062831.GA20202@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VbJkn9YxBvnuCH5J"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

It looks like some of the places where FIB_SCAN_TOS macros were used
have lost the tos check.  This patch adds them back.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/fib_hash.c 1.24 vs edited =====
--- 1.24/net/ipv4/fib_hash.c	2004-09-23 16:10:05 +10:00
+++ edited/net/ipv4/fib_hash.c	2004-09-23 16:16:48 +10:00
@@ -538,6 +538,8 @@
 		 */
 		fa_orig = fa;
 		list_for_each_entry(fa, fa_orig->fa_list.prev, fa_list) {
+			if (fa->fa_tos != tos)
+				break;
 			if (fa->fa_info->fib_priority != fi->fib_priority)
 				break;
 			if (fa->fa_type == type &&
@@ -636,6 +638,9 @@
 	fa_to_delete = NULL;
 	list_for_each_entry(fa, fa->fa_list.prev, fa_list) {
 		struct fib_info *fi = fa->fa_info;
+
+		if (fa->fa_tos != tos)
+			break;
 
 		if ((!r->rtm_type ||
 		     fa->fa_type == r->rtm_type) &&

--VbJkn9YxBvnuCH5J--
