From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH] bridge: Pull ip header into skb->data before looking into ip header.
Date: Wed, 10 Oct 2012 16:45:01 +0530
Message-ID: <6f6f2599-15e5-49a7-973c-d2c36483427d@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:16586 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755896Ab2JJLPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 07:15:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

If lower layer driver leaves the ip header in the skb fragment, it needs to
be first pulled into skb->data before inspecting ip header length or ip version
number.

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 net/bridge/br_netfilter.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 68e8f36..fe43bc7 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -265,6 +265,9 @@ static int br_parse_ip_options(struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	u32 len;
 
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		goto inhdr_error;
+
 	iph = ip_hdr(skb);
 	opt = &(IPCB(skb)->opt);
 
-- 
1.7.9.5
