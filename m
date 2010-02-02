From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-next-2.6] bonding: Remove net_device_stats from bonding
 struct
Date: Tue, 2 Feb 2010 05:36:52 +0530
Message-ID: <20100202000648.GA30286@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Ajit Khaparde <ajitk@serverengines.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.211.173]:34478 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218Ab0BBAGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 19:06:44 -0500
Received: by ywh3 with SMTP id 3so2164533ywh.22
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2010 16:06:43 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to maintain stats in the bonding structure.
Use the instance of net_device_stats in netdevice.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 drivers/net/bonding/bonding.h   |    1 -
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6221936..1787e3c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3742,7 +3742,7 @@ static int bond_close(struct net_device *bond_dev)
 static struct net_device_stats *bond_get_stats(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct net_device_stats *stats = &bond->stats;
+	struct net_device_stats *stats = &bond_dev->stats;
 	struct net_device_stats local_stats;
 	struct slave *slave;
 	int i;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 558ec13..257a7a4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -197,7 +197,6 @@ struct bonding {
 	s8	 send_grat_arp;
 	s8	 send_unsol_na;
 	s8	 setup_by_slave;
-	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;
 	char     proc_file_name[IFNAMSIZ];
-- 
1.6.3.3

