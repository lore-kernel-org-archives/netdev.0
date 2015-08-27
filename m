From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v5 net-next 1/8] geneve: Initialize ethernet address in device setup.
Date: Wed, 26 Aug 2015 23:46:48 -0700
Message-ID: <1440658015-13028-2-git-send-email-pshelar@nicira.com>
References: <1440658015-13028-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34846 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbbH0GrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 02:47:02 -0400
Received: by pacdd16 with SMTP id dd16so15011343pac.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 23:47:01 -0700 (PDT)
In-Reply-To: <1440658015-13028-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Reviewed-by: Jesse Gross <jesse@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
Acked-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/geneve.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 897e1a3..95e9da0 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -297,6 +297,7 @@ static void geneve_setup(struct net_device *dev)
 
 	netif_keep_dst(dev);
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
+	eth_hw_addr_random(dev);
 }
 
 static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
@@ -364,9 +365,6 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 			return -EBUSY;
 	}
 
-	if (tb[IFLA_ADDRESS] == NULL)
-		eth_hw_addr_random(dev);
-
 	err = register_netdevice(dev);
 	if (err)
 		return err;
-- 
1.7.1
