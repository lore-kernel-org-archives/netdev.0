From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 2/9] geneve: Use skb mark and protocol to lookup route.
Date: Mon, 17 Aug 2015 14:11:38 -0700
Message-ID: <1439845905-31666-3-git-send-email-pshelar@nicira.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33215 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbbHQVLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:11:53 -0400
Received: by pabyb7 with SMTP id yb7so116213699pab.0
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:11:53 -0700 (PDT)
In-Reply-To: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On packet transmit path geneve need to lookup route. Following
patch improves route lookup using more parameters.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/geneve.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 51f7f8b..4f4d15e 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -202,6 +202,9 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.flowi4_tos = RT_TOS(tos);
 	fl4.daddr = geneve->remote.sin_addr.s_addr;
+	fl4.flowi4_mark = skb->mark;
+	fl4.flowi4_proto = IPPROTO_UDP;
+
 	rt = ip_route_output_key(geneve->net, &fl4);
 	if (IS_ERR(rt)) {
 		netdev_dbg(dev, "no route to %pI4\n", &fl4.daddr);
-- 
1.8.3.1
