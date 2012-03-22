From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] netlabel: use GFP flags from caller instead of GFP_ATOMIC
Date: Thu, 22 Mar 2012 09:41:01 +0300
Message-ID: <20120322064101.GD7369@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:29712 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756Ab2CVGlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 02:41:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function takes a GFP flags as a parameter, but they are never used.
We don't take a lock in this function so there is no reason to prefer
GFP_ATOMIC over the caller's GFP flags.

There is only one caller, cipso_v4_map_cat_rng_ntoh(), and it passes
GFP_ATOMIC as the GFP flags so this doesn't change how the code works.
It's just a cleanup.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 2560e7b..7c94aed 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -597,7 +597,7 @@ int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap *catmap,
 			iter = iter->next;
 			iter_max_spot = iter->startbit + NETLBL_CATMAP_SIZE;
 		}
-		ret_val = netlbl_secattr_catmap_setbit(iter, spot, GFP_ATOMIC);
+		ret_val = netlbl_secattr_catmap_setbit(iter, spot, flags);
 	}
 
 	return ret_val;
