From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 1/9] geneve: Initialize ethernet address in device setup.
Date: Mon, 17 Aug 2015 14:11:37 -0700
Message-ID: <1439845905-31666-2-git-send-email-pshelar@nicira.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33203 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbbHQVLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:11:52 -0400
Received: by pabyb7 with SMTP id yb7so116213370pab.0
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:11:51 -0700 (PDT)
In-Reply-To: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/geneve.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 78d49d1..51f7f8b 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -298,6 +298,7 @@ static void geneve_setup(struct net_device *dev)
 
 	netif_keep_dst(dev);
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	eth_hw_addr_random(dev);
 }
 
 static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
@@ -365,9 +366,6 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 			return -EBUSY;
 	}
 
-	if (tb[IFLA_ADDRESS] == NULL)
-		eth_hw_addr_random(dev);
-
 	err = register_netdevice(dev);
 	if (err)
 		return err;
-- 
1.8.3.1
