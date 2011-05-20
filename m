From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch 3/3] net: rename NETDEV_BONDING_DESLAVE to NETDEV_RELEASE
Date: Fri, 20 May 2011 15:39:12 +0800
Message-ID: <1305877152-30970-3-git-send-email-amwang@redhat.com>
References: <1305877152-30970-1-git-send-email-amwang@redhat.com>
Cc: WANG Cong <amwang@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Neil Horman <nhorman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52413 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934230Ab1ETHjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2011 03:39:25 -0400
In-Reply-To: <1305877152-30970-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

s/NETDEV_BONDING_DESLAVE/NETDEV_RELEASE/ as Andy suggested.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: Neil Horman <nhorman@redhat.com>

---
 drivers/net/bonding/bond_main.c |    2 +-
 drivers/net/netconsole.c        |    6 +++---
 include/linux/notifier.h        |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f4960f5..6dc4284 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1974,7 +1974,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	block_netpoll_tx();
-	netdev_bonding_change(bond_dev, NETDEV_BONDING_DESLAVE);
+	netdev_bonding_change(bond_dev, NETDEV_RELEASE);
 	write_lock_bh(&bond->lock);
 
 	slave = bond_get_slave_by_dev(bond, slave_dev);
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 4190786..dfc8272 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -621,7 +621,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
 	bool stopped = false;
 
 	if (!(event == NETDEV_CHANGENAME || event == NETDEV_UNREGISTER ||
-	      event == NETDEV_BONDING_DESLAVE || event == NETDEV_JOIN))
+	      event == NETDEV_RELEASE || event == NETDEV_JOIN))
 		goto done;
 
 	spin_lock_irqsave(&target_list_lock, flags);
@@ -632,7 +632,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
 			case NETDEV_CHANGENAME:
 				strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
 				break;
-			case NETDEV_BONDING_DESLAVE:
+			case NETDEV_RELEASE:
 			case NETDEV_JOIN:
 			case NETDEV_UNREGISTER:
 				/*
@@ -664,7 +664,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
 		case NETDEV_UNREGISTER:
 			printk(KERN_CONT "unregistered\n");
 			break;
-		case NETDEV_BONDING_DESLAVE:
+		case NETDEV_RELEASE:
 			printk(KERN_CONT "released slaves\n");
 			break;
 		case NETDEV_JOIN:
diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index a577762..c0688b0 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -209,7 +209,7 @@ static inline int notifier_to_errno(int ret)
 #define NETDEV_POST_TYPE_CHANGE	0x000F
 #define NETDEV_POST_INIT	0x0010
 #define NETDEV_UNREGISTER_BATCH 0x0011
-#define NETDEV_BONDING_DESLAVE  0x0012
+#define NETDEV_RELEASE		0x0012
 #define NETDEV_NOTIFY_PEERS	0x0013
 #define NETDEV_JOIN		0x0014
 
-- 
1.7.1

