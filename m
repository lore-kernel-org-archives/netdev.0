From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/2] ethtool: allow const ethtool_ops
Date: Fri, 8 Sep 2006 11:16:13 -0700
Message-ID: <20060908111613.12c1f9b8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:1178 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751041AbWIHSQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 14:16:59 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool_ops structure is immutable, it expected to be setup
by the driver and is never changed. This patch allows drivers to
declare there ethtool_ops structure read-only.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- linux-2.6.orig/include/linux/netdevice.h
+++ linux-2.6/include/linux/netdevice.h
@@ -342,7 +342,7 @@ struct net_device
 	/* Instance data managed by the core of Wireless Extensions. */
 	struct iw_public_data *	wireless_data;
 
-	struct ethtool_ops *ethtool_ops;
+	const struct ethtool_ops *ethtool_ops;
 
 	/*
 	 * This marks the end of the "visible" part of the structure. All
--- linux-2.6.orig/net/core/ethtool.c
+++ linux-2.6/net/core/ethtool.c
@@ -143,7 +143,7 @@ static int ethtool_set_settings(struct n
 static int ethtool_get_drvinfo(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_drvinfo info;
-	struct ethtool_ops *ops = dev->ethtool_ops;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
 
 	if (!ops->get_drvinfo)
 		return -EOPNOTSUPP;
@@ -169,7 +169,7 @@ static int ethtool_get_drvinfo(struct ne
 static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_regs regs;
-	struct ethtool_ops *ops = dev->ethtool_ops;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
 	void *regbuf;
 	int reglen, ret;
 
@@ -282,7 +282,7 @@ static int ethtool_get_link(struct net_d
 static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_eeprom eeprom;
-	struct ethtool_ops *ops = dev->ethtool_ops;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
 	u8 *data;
 	int ret;
 
@@ -327,7 +327,7 @@ static int ethtool_get_eeprom(struct net
 static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_eeprom eeprom;
-	struct ethtool_ops *ops = dev->ethtool_ops;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
 	u8 *data;
 	int ret;
 
@@ -640,7 +640,7 @@ static int ethtool_set_gso(struct net_de
 static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_test test;
-	struct ethtool_ops *ops = dev->ethtool_ops;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
 	u64 *data;
 	int ret;
 
@@ -673,7 +673,7 @@ static int ethtool_self_test(struct net_
 static int ethtool_get_strings(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_gstrings gstrings;
-	struct ethtool_ops *ops = dev->ethtool_ops;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
 	u8 *data;
 	int ret;
 
@@ -733,7 +733,7 @@ static int ethtool_phys_id(struct net_de
 static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_stats stats;
-	struct ethtool_ops *ops = dev->ethtool_ops;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
 	u64 *data;
 	int ret;
 
