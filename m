From: Doug Goldstein <cardoe@cardoe.com>
Subject: [PATCHv2] bonding: set sysfs device_type to 'bond'
Date: Mon, 18 Feb 2013 18:59:23 -0600
Message-ID: <1361235563-2684-1-git-send-email-cardoe@cardoe.com>
References: <20130218.144934.1015644582010518018.davem@davemloft.net>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	Doug Goldstein <cardoe@cardoe.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f169.google.com ([209.85.213.169]:55663 "EHLO
	mail-ye0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757872Ab3BSB4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 20:56:10 -0500
Received: by mail-ye0-f169.google.com with SMTP id l13so1145821yen.28
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 17:56:08 -0800 (PST)
In-Reply-To: <20130218.144934.1015644582010518018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sets the sysfs device_type to 'bond' for udev. This allows udev rules to
be created for bond devices. This is similar to how other network
devices set their device_type.

Signed-off-by: Doug Goldstein <cardoe@cardoe.com>
---
v2: removed accidental whitespace addition
---
 drivers/net/bonding/bond_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b7d45f3..876505f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4352,6 +4352,10 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_fix_features	= bond_fix_features,
 };
 
+static const struct device_type bond_type = {
+	.name = "bond",
+};
+
 static void bond_destructor(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -4382,6 +4386,8 @@ static void bond_setup(struct net_device *bond_dev)
 
 	bond_dev->destructor = bond_destructor;
 
+	SET_NETDEV_DEVTYPE(bond_dev, &bond_type);
+
 	/* Initialize the device options */
 	bond_dev->tx_queue_len = 0;
 	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
-- 
1.7.12.4
