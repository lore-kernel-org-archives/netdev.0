From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/6] net: dsa: Export dev_to_net_device()
Date: Mon, 27 Jun 2016 17:52:42 -0700
Message-ID: <1467075163-15890-6-git-send-email-f.fainelli@gmail.com>
References: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36704 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbcF1Aww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 20:52:52 -0400
Received: by mail-oi0-f67.google.com with SMTP id x6so257777oif.3
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 17:52:52 -0700 (PDT)
In-Reply-To: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are going to need this in net/dsa/dsa2.c as well, so make it
avaialable.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 1 +
 net/dsa/dsa.c     | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 6de162c8283e..48dce1fd100a 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -369,6 +369,7 @@ struct dsa_switch_driver {
 void register_switch_driver(struct dsa_switch_driver *type);
 void unregister_switch_driver(struct dsa_switch_driver *type);
 struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
+struct net_device *dev_to_net_device(struct device *dev);
 
 static inline void *ds_to_priv(struct dsa_switch *ds)
 {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index d117580a78b6..9b5ff9814b5e 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -626,7 +626,7 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev)
 }
 EXPORT_SYMBOL_GPL(dsa_host_dev_to_mii_bus);
 
-static struct net_device *dev_to_net_device(struct device *dev)
+struct net_device *dev_to_net_device(struct device *dev)
 {
 	struct device *d;
 
@@ -643,6 +643,7 @@ static struct net_device *dev_to_net_device(struct device *dev)
 
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(dev_to_net_device);
 
 #ifdef CONFIG_OF
 static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
-- 
2.7.4
