From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 2/7] xfrm_state: Make sure alg_name is NULL-terminated
Date: Thu, 17 Aug 2017 19:09:27 +0200
Message-ID: <20170817170932.24659-3-phil@nwl.cc>
References: <20170817170932.24659-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42137 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753723AbdHQRON (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:14:13 -0400
In-Reply-To: <20170817170932.24659-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/xfrm_state.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index e11c93bf1c3b5..7c0389038986e 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -125,7 +125,8 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 	fprintf(stderr, "warning: ALGO-NAME/ALGO-KEYMAT values will be sent to the kernel promiscuously! (verifying them isn't implemented yet)\n");
 #endif
 
-	strncpy(alg->alg_name, name, sizeof(alg->alg_name));
+	strncpy(alg->alg_name, name, sizeof(alg->alg_name) - 1);
+	alg->alg_name[sizeof(alg->alg_name) - 1] = '\0';
 
 	if (slen > 2 && strncmp(key, "0x", 2) == 0) {
 		/* split two chars "0x" from the top */
-- 
2.13.1
