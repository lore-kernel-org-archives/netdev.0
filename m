From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] Fix af_key.c compiler warning
Date: Thu, 24 Apr 2008 22:53:38 -0400
Message-ID: <481147B2.3020801@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010208050309090409090407"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:46068 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219AbYDYCxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 22:53:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010208050309090409090407
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit


net/key/af_key.c: In function ‘pfkey_spddelete’:
net/key/af_key.c:2359: warning: ‘pol_ctx’ may be used uninitialized in 
this function

When CONFIG_SECURITY_NETWORK_XFRM isn't set, 
security_xfrm_policy_alloc() is an inline that doesn't set pol_ctx, so 
this seemed like the easiest fix short of using *uninitialized_var(pol_ctx).

-Brian

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

--------------010208050309090409090407
Content-Type: text/x-patch;
 name="pol_ctx.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pol_ctx.patch"

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 81a8e52..2403a31 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2356,7 +2356,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 	struct xfrm_selector sel;
 	struct km_event c;
 	struct sadb_x_sec_ctx *sec_ctx;
-	struct xfrm_sec_ctx *pol_ctx;
+	struct xfrm_sec_ctx *pol_ctx = NULL;
 
 	if (!present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
 				     ext_hdrs[SADB_EXT_ADDRESS_DST-1]) ||
@@ -2396,8 +2396,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 		kfree(uctx);
 		if (err)
 			return err;
-	} else
-		pol_ctx = NULL;
+	}
 
 	xp = xfrm_policy_bysel_ctx(XFRM_POLICY_TYPE_MAIN,
 				   pol->sadb_x_policy_dir - 1, &sel, pol_ctx,

--------------010208050309090409090407--
