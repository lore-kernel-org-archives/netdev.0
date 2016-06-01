From: Kangjie Lu <kangjielu@gmail.com>
Subject: [PATCH] ethtool: fix a kernel infoleak in ethtool_get_pauseparam
Date: Wed,  1 Jun 2016 16:39:21 +0200
Message-ID: <1464791961-8169-1-git-send-email-kjlu@gatech.edu>
Cc: ben@decadent.org.uk, kan.liang@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	csong84@gatech.edu, Kangjie Lu <kjlu@gatech.edu>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The field autoneg of pauseparam is not initialized in some
implementations of get_pauseparam(), but the whole object is
copied to userland.

Signed-off-by: Kangjie Lu <kjlu@gatech.edu>
---
 net/core/ethtool.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f426c5a..84544bd 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1723,7 +1723,10 @@ static noinline_for_stack int ethtool_set_channels(struct net_device *dev,
 
 static int ethtool_get_pauseparam(struct net_device *dev, void __user *useraddr)
 {
-	struct ethtool_pauseparam pauseparam = { ETHTOOL_GPAUSEPARAM };
+	struct ethtool_pauseparam pauseparam;
+
+	memset(&pauseparam, 0, sizeof(pauseparam));
+	pauseparam.cmd = ETHTOOL_GPAUSEPARAM;
 
 	if (!dev->ethtool_ops->get_pauseparam)
 		return -EOPNOTSUPP;
-- 
1.9.1
