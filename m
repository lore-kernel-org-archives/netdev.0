From: Andreas Steffen <andreas.steffen@strongswan.org>
Subject: [PATCH] xfrm: fix XFRMA_MARK extraction in xfrm_mark_get
Date: Wed, 30 Jun 2010 09:57:34 +0200
Message-ID: <4C2AF8EE.8030508@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80024.hsr.ch ([152.96.80.24]:42260 "EHLO strongswan.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191Ab0F3JOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 05:14:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Determine the size of the xfrm_mark struct, not of its pointer.

Signed-off-by: Andreas Steffen <andreas.steffen@strongswan.org>
---
 include/net/xfrm.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1913af6..fc8f36d 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1586,7 +1586,7 @@ static inline struct xfrm_state *xfrm_input_state(struct sk_buff *skb)
 static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_mark *m)
 {
 	if (attrs[XFRMA_MARK])
-		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(m));
+		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(struct xfrm_mark));
 	else
 		m->v = m->m = 0;
 
-- 
1.7.0.4
