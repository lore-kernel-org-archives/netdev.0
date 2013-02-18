From: Doug Goldstein <cardoe@cardoe.com>
Subject: [PATCH] bonding: set sysfs device_type to 'bond'
Date: Sun, 17 Feb 2013 20:38:47 -0600
Message-ID: <1361155127-4415-1-git-send-email-cardoe@cardoe.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Doug Goldstein <cardoe@cardoe.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f181.google.com ([209.85.161.181]:37696 "EHLO
	mail-gg0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755904Ab3BRCix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 21:38:53 -0500
Received: by mail-gg0-f181.google.com with SMTP id e5so489047ggh.12
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2013 18:38:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sets the sysfs device_type to 'bond' for udev. This allows udev rules to
be created for bond devices. This is similar to how other network
devices set their device_type.

Signed-off-by: Doug Goldstein <cardoe@cardoe.com>
---
 drivers/net/bonding/bond_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b7d45f3..34a6e96 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4350,6 +4350,10 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_add_slave		= bond_enslave,
 	.ndo_del_slave		= bond_release,
 	.ndo_fix_features	= bond_fix_features,
+}; 
+
+static const struct device_type bond_type = {
+	.name = "bond",
 };
 
 static void bond_destructor(struct net_device *bond_dev)
@@ -4382,6 +4386,8 @@ static void bond_setup(struct net_device *bond_dev)
 
 	bond_dev->destructor = bond_destructor;
 
+	SET_NETDEV_DEVTYPE(bond_dev, &bond_type);
+
 	/* Initialize the device options */
 	bond_dev->tx_queue_len = 0;
 	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
-- 
1.7.12.4
