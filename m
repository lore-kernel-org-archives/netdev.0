From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] mlxsw: spectrum: remove redundant check if err is zero
Date: Sat, 24 Sep 2016 18:03:38 -0700
Message-ID: <20160925010338.2734-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

There is an earlier check and return if err is non-zero, so
the check to see if it is zero is redundant in every iteration
of the loop and hence the check can be removed.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
index 2a61617..1073673 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
@@ -117,11 +117,11 @@ static int validate_filter(struct net_device *dev,
 	return 0;
 }
 
-static unsigned int get_filter_steerq(struct net_device *dev,
-				      struct ch_filter_specification *fs)
+static int get_filter_steerq(struct net_device *dev,
+			     struct ch_filter_specification *fs)
 {
 	struct adapter *adapter = netdev2adap(dev);
-	unsigned int iq;
+	int iq;
 
 	/* If the user has requested steering matching Ingress Packets
 	 * to a specific Queue Set, we need to make sure it's in range
@@ -443,10 +443,10 @@ int __cxgb4_set_filter(struct net_device *dev, int filter_id,
 		       struct filter_ctx *ctx)
 {
 	struct adapter *adapter = netdev2adap(dev);
-	unsigned int max_fidx, fidx, iq;
+	unsigned int max_fidx, fidx;
 	struct filter_entry *f;
 	u32 iconf;
-	int ret;
+	int iq, ret;
 
 	max_fidx = adapter->tids.nftids;
 	if (filter_id != (max_fidx + adapter->tids.nsftids - 1) &&
-- 
2.9.3
