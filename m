From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v4 net-next 1/8] geneve: Initialize ethernet address in device setup.
Date: Wed, 26 Aug 2015 14:54:32 -0700
Message-ID: <1440626079-11689-2-git-send-email-pshelar@nicira.com>
References: <1440626079-11689-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36480 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbbHZVyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 17:54:44 -0400
Received: by pacgr6 with SMTP id gr6so798351pac.3
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 14:54:44 -0700 (PDT)
In-Reply-To: <1440626079-11689-1-git-send-email-pshelar@nicira.com>
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
