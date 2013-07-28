From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -mainline v2] af_key: more info leaks in pfkey messages
Date: Sun, 28 Jul 2013 23:04:45 +0300
Message-ID: <20130728200444.GA8684@elgon.mountain>
References: <20130725073205.GQ3109@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130725073205.GQ3109@secunet.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is inspired by a5cc68f3d6 "af_key: fix info leaks in notify
messages".  There are some struct members which don't get initialized
and could disclose small amounts of private information.

Acked-by: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: set ->sadb_x_policy_priority correctly instead of just clearing it

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 456b262..d49f676 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2081,6 +2081,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 			pol->sadb_x_policy_type = IPSEC_POLICY_NONE;
 	}
 	pol->sadb_x_policy_dir = dir+1;
+	pol->sadb_x_policy_reserved = 0;
 	pol->sadb_x_policy_id = xp->index;
 	pol->sadb_x_policy_priority = xp->priority;
 
@@ -3137,7 +3138,9 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	pol->sadb_x_policy_exttype = SADB_X_EXT_POLICY;
 	pol->sadb_x_policy_type = IPSEC_POLICY_IPSEC;
 	pol->sadb_x_policy_dir = XFRM_POLICY_OUT + 1;
+	pol->sadb_x_policy_reserved = 0;
 	pol->sadb_x_policy_id = xp->index;
+	pol->sadb_x_policy_priority = xp->priority;
 
 	/* Set sadb_comb's. */
 	if (x->id.proto == IPPROTO_AH)
@@ -3525,6 +3528,7 @@ static int pfkey_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	pol->sadb_x_policy_exttype = SADB_X_EXT_POLICY;
 	pol->sadb_x_policy_type = IPSEC_POLICY_IPSEC;
 	pol->sadb_x_policy_dir = dir + 1;
+	pol->sadb_x_policy_reserved = 0;
 	pol->sadb_x_policy_id = 0;
 	pol->sadb_x_policy_priority = 0;
 
