From: Patrick McHardy <kaber@trash.net>
Subject: [IPSEC]: Protect against BHs in xfrm_user_policy()
Date: Sun, 03 Apr 2005 18:13:01 +0200
Message-ID: <4250160D.2040405@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040106090202000803080206"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040106090202000803080206
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

xfrm_user_policy() is called from ip_setsockopt with enabled
BHs, so it needs to protect against them when grabbing
xfrm_km_lock.


--------------040106090202000803080206
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/04/03 17:36:10+02:00 kaber@coreworks.de 
#   [IPSEC]: Protect against BHs in xfrm_user_policy()
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/xfrm/xfrm_state.c
#   2005/04/03 17:36:00+02:00 kaber@coreworks.de +2 -2
#   [IPSEC]: Protect against BHs in xfrm_user_policy()
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c	2005-04-03 18:04:38 +02:00
+++ b/net/xfrm/xfrm_state.c	2005-04-03 18:04:38 +02:00
@@ -878,14 +878,14 @@
 		goto out;
 
 	err = -EINVAL;
-	read_lock(&xfrm_km_lock);
+	read_lock_bh(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list) {
 		pol = km->compile_policy(sk->sk_family, optname, data,
 					 optlen, &err);
 		if (err >= 0)
 			break;
 	}
-	read_unlock(&xfrm_km_lock);
+	read_unlock_bh(&xfrm_km_lock);
 
 	if (err >= 0) {
 		xfrm_sk_policy_insert(sk, err, pol);

--------------040106090202000803080206--
