From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next] lwtunnel: subtract tunnel headroom from mtu on output redirect
Date: Wed, 16 Nov 2016 10:05:46 +0100
Message-ID: <1479287146-25766-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <roopa@cumulusnetworks.com>,
        David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:36278 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752352AbcKPJEC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 04:04:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the lwtunnel_headroom() function which is called
in ipv4_mtu() and ip6_mtu(), to also return the correct headroom
value when the lwtunnel state is OUTPUT_REDIRECT.

This patch enables e.g. SR-IPv6 encapsulations to work without
manually setting the route mtu.

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/net/lwtunnel.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index 82e76fe..d4c1c75 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -94,7 +94,8 @@ static inline bool lwtunnel_xmit_redirect(struct lwtunnel_state *lwtstate)
 static inline unsigned int lwtunnel_headroom(struct lwtunnel_state *lwtstate,
 					     unsigned int mtu)
 {
-	if (lwtunnel_xmit_redirect(lwtstate) && lwtstate->headroom < mtu)
+	if ((lwtunnel_xmit_redirect(lwtstate) ||
+	     lwtunnel_output_redirect(lwtstate)) && lwtstate->headroom < mtu)
 		return lwtstate->headroom;
 
 	return 0;
-- 
2.7.3
