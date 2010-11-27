From: "Scott J. Goldman" <scottjg@vmware.com>
Subject: [PATCH] vmxnet3: fix compilation when RSS is disabled
Date: Sat, 27 Nov 2010 12:33:55 -0800
Message-ID: <1290890035-32285-2-git-send-email-scottjg@vmware.com>
References: <1290890035-32285-1-git-send-email-scottjg@vmware.com>
Cc: pv-drivers@vmware.com, randy.dunlap@oracle.com,
	"Scott J. Goldman" <scottjg@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1290890035-32285-1-git-send-email-scottjg@vmware.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If RSS is disabled, we can ifdef out some RSS specific code. This fixes
the compile error found by Randy Dunlap.

Signed-off-by: Scott J. Goldman <scottjg@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_ethtool.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 9ddaea6..8e17fc8 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -553,7 +553,7 @@ vmxnet3_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *info,
 	return -EOPNOTSUPP;
 }
 
-
+#ifdef VMXNET3_RSS
 static int
 vmxnet3_get_rss_indir(struct net_device *netdev,
 		      struct ethtool_rxfh_indir *p)
@@ -598,6 +598,7 @@ vmxnet3_set_rss_indir(struct net_device *netdev,
 	return 0;
 
 }
+#endif
 
 static struct ethtool_ops vmxnet3_ethtool_ops = {
 	.get_settings      = vmxnet3_get_settings,
@@ -623,8 +624,10 @@ static struct ethtool_ops vmxnet3_ethtool_ops = {
 	.get_ringparam     = vmxnet3_get_ringparam,
 	.set_ringparam     = vmxnet3_set_ringparam,
 	.get_rxnfc         = vmxnet3_get_rxnfc,
+#ifdef VMXNET3_RSS
 	.get_rxfh_indir    = vmxnet3_get_rss_indir,
 	.set_rxfh_indir    = vmxnet3_set_rss_indir,
+#endif
 };
 
 void vmxnet3_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.0.4
