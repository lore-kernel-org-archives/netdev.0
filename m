From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 16/51] xfrm_state: Make sure alg_name is NULL-terminated
Date: Sat, 12 Aug 2017 14:04:35 +0200
Message-ID: <20170812120510.28750-17-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37201 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752318AbdHLMJP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:09:15 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
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
