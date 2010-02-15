From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ethtool: reduce stack usage
Date: Mon, 15 Feb 2010 15:24:00 +0100
Message-ID: <1266243840.8262.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:46908 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244Ab0BOOYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 09:24:09 -0500
Received: by bwz5 with SMTP id 5so1033507bwz.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 06:24:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_ethtool() is currently using 604 bytes of stack, even with gcc-4.4.2

objdump -d vmlinux | scripts/checkstack.pl
...
0xc04bbc33 dev_ethtool [vmlinux]:			604
...
Adding noinline attributes to selected functions can reduce stack usage.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/ethtool.c |   35 ++++++++++++++++++++++++++++-------
 1 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index a1280f6..eb41ef6 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -191,7 +191,10 @@ static int ethtool_set_settings(struct net_device *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_settings(dev, &cmd);
 }
 
-static int ethtool_get_drvinfo(struct net_device *dev, void __user *useraddr)
+/*
+ * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
+ */
+static noinline int ethtool_get_drvinfo(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_drvinfo info;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
@@ -226,7 +229,10 @@ static int ethtool_get_drvinfo(struct net_device *dev, void __user *useraddr)
 	return 0;
 }
 
-static int ethtool_set_rxnfc(struct net_device *dev, void __user *useraddr)
+/*
+ * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
+ */
+static noinline int ethtool_set_rxnfc(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_rxnfc cmd;
 
@@ -239,7 +245,10 @@ static int ethtool_set_rxnfc(struct net_device *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_rxnfc(dev, &cmd);
 }
 
-static int ethtool_get_rxnfc(struct net_device *dev, void __user *useraddr)
+/*
+ * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
+ */
+static noinline int ethtool_get_rxnfc(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_rxnfc info;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
@@ -314,7 +323,10 @@ static int __rx_ntuple_filter_add(struct ethtool_rx_ntuple_list *list,
 	return 0;
 }
 
-static int ethtool_set_rx_ntuple(struct net_device *dev, void __user *useraddr)
+/*
+ * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
+ */
+static noinline int ethtool_set_rx_ntuple(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_rx_ntuple cmd;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
@@ -777,7 +789,10 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
 	return ret;
 }
 
-static int ethtool_get_coalesce(struct net_device *dev, void __user *useraddr)
+/*
+ * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
+ */
+static noinline int ethtool_get_coalesce(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_coalesce coalesce = { .cmd = ETHTOOL_GCOALESCE };
 
@@ -791,7 +806,10 @@ static int ethtool_get_coalesce(struct net_device *dev, void __user *useraddr)
 	return 0;
 }
 
-static int ethtool_set_coalesce(struct net_device *dev, void __user *useraddr)
+/*
+ * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
+ */
+static noinline int ethtool_set_coalesce(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_coalesce coalesce;
 
@@ -1201,7 +1219,10 @@ static int ethtool_set_value(struct net_device *dev, char __user *useraddr,
 	return actor(dev, edata.data);
 }
 
-static int ethtool_flash_device(struct net_device *dev, char __user *useraddr)
+/*
+ * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
+ */
+static noinline int ethtool_flash_device(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_flash efl;
 


