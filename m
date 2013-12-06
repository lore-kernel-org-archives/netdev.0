From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 1/5] {pktgen, xfrm} Remove original pktgen ipsec fixed configuration
Date: Fri, 6 Dec 2013 17:53:30 +0800
Message-ID: <1386323614-5077-2-git-send-email-fan.du@windriver.com>
References: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50700 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756786Ab3LFJxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 04:53:38 -0500
In-Reply-To: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup original fixed IPsec output mode and encapuslation type,
As following patchset enable user to configure IPsec attribute.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/core/pktgen.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index a797fff..e6820e5 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -387,8 +387,6 @@ struct pktgen_dev {
 	int node;               /* Memory node */
 
 #ifdef CONFIG_XFRM
-	__u8	ipsmode;		/* IPSEC mode (config) */
-	__u8	ipsproto;		/* IPSEC type (config) */
 #endif
 	char result[512];
 };
@@ -2482,10 +2480,6 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 
 	if (!x)
 		return 0;
-	/* XXX: we dont support tunnel mode for now until
-	 * we resolve the dst issue */
-	if (x->props.mode != XFRM_MODE_TRANSPORT)
-		return 0;
 
 	spin_lock(&x->lock);
 
@@ -3540,8 +3534,6 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 		goto out2;
 	}
 #ifdef CONFIG_XFRM
-	pkt_dev->ipsmode = XFRM_MODE_TRANSPORT;
-	pkt_dev->ipsproto = IPPROTO_ESP;
 #endif
 
 	return add_dev_to_thread(t, pkt_dev);
-- 
1.7.9.5
