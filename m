From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/10] drivers/net/bonding: Remove unnecessary casts of netdev_priv
Date: Mon, 15 Nov 2010 13:12:25 -0800
Message-ID: <6cbd8cc45eab4a2f85017c5b7ea926781d977c05.1289855436.git.joe@perches.com>
References: <cover.1289855436.git.joe@perches.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1289855436.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_3ad.c |    3 +--
 drivers/net/bonding/bonding.h  |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 106718c..171782e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2474,8 +2474,7 @@ int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct pac
 		goto out;
 
 	read_lock(&bond->lock);
-	slave = bond_get_slave_by_dev((struct bonding *)netdev_priv(dev),
-					orig_dev);
+	slave = bond_get_slave_by_dev(netdev_priv(dev), orig_dev);
 	if (!slave)
 		goto out_unlock;
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4eedb12..ad3ae46 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -286,7 +286,7 @@ static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
 		return NULL;
 	}
 
-	return (struct bonding *)netdev_priv(slave->dev->master);
+	return netdev_priv(slave->dev->master);
 }
 
 static inline bool bond_is_lb(const struct bonding *bond)
-- 
1.7.3.1.g432b3.dirty
