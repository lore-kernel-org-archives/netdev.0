From: Jamal Hadi Salim <hadi@znyx.com>
Subject: patch: policy update by id
Date: Wed, 27 Apr 2005 07:54:34 -0400
Message-ID: <1114602874.7670.4.camel@localhost.localdomain>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hAbxU4CA+qUy6baSQSE7"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-hAbxU4CA+qUy6baSQSE7
Content-Transfer-Encoding: 7bit
Content-Type: text/plain


Herbert,

I think this is a reasonable thing to have. I should be able to update
(just like delete or get) a policy by id. And that it trumps a selector
when both are specified..
I am assuming ids are unique - otherwise we have a serious problem.
If this patch looks good, please add it to your patch collection that
you are queueing for Dave; btw - is that stuff supposed to show up
around .13?

cheers,
jamal

--=-hAbxU4CA+qUy6baSQSE7
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=polid_p
Content-Type: text/plain; name=polid_p; charset=UTF-8

--- a/net/xfrm/xfrm_policy.c	2005/04/27 11:32:13	1.1
+++ b/net/xfrm/xfrm_policy.c	2005/04/27 11:48:42
@@ -345,7 +345,9 @@
 
 	write_lock_bh(&xfrm_policy_lock);
 	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL;) {
-		if (!delpol && memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0) {
+		if (!delpol && 
+		((!excl && policy->id && (policy->id == pol->id)) || 
+		 (memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0))) {
 			if (excl) {
 				write_unlock_bh(&xfrm_policy_lock);
 				return -EEXIST;

--=-hAbxU4CA+qUy6baSQSE7--
