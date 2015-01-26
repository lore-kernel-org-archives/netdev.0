From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH net-next v2 1/5] bonding: update bond carrier state when min_links option changes
Date: Mon, 26 Jan 2015 01:16:57 -0500
Message-ID: <1422253021-3798-2-git-send-email-jtoppins@cumulusnetworks.com>
References: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:43782 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718AbbAZGUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 01:20:15 -0500
Received: by mail-qg0-f51.google.com with SMTP id z107so5568521qgd.10
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 22:20:15 -0800 (PST)
In-Reply-To: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c    |    2 +-
 drivers/net/bonding/bond_options.c |    1 +
 include/net/bonding.h              |    1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0dceba1..02ffedb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -334,7 +334,7 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
  *
  * Returns zero if carrier state does not change, nonzero if it does.
  */
-static int bond_set_carrier(struct bonding *bond)
+int bond_set_carrier(struct bonding *bond)
 {
 	struct list_head *iter;
 	struct slave *slave;
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 9bd538d4..4df2894 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -1181,6 +1181,7 @@ static int bond_option_min_links_set(struct bonding *bond,
 	netdev_info(bond->dev, "Setting min links value to %llu\n",
 		    newval->value);
 	bond->params.min_links = newval->value;
+	bond_set_carrier(bond);
 
 	return 0;
 }
diff --git a/include/net/bonding.h b/include/net/bonding.h
index 983a94b..29f53ea 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -525,6 +525,7 @@ void bond_sysfs_slave_del(struct slave *slave);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
 u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb);
+int bond_set_carrier(struct bonding *bond);
 void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_create_debugfs(void);
-- 
1.7.10.4
