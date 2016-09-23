From: Colin King <colin.king@canonical.com>
Subject: [PATCH] cxgb4: fix -ve error check on a signed iq
Date: Fri, 23 Sep 2016 14:45:13 +0100
Message-ID: <20160923134513.21345-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Hariprasad S <hariprasad@chelsio.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

iq is unsigned, so the error check for iq < 0 has no effect so errors
can slip past this check.  Fix this by making iq signed and also
get_filter_steerq return a signed int so a -ve error can be returned.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
index 2a61617..9c3644d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
@@ -117,11 +117,11 @@ static int validate_filter(struct net_device *dev,
 	return 0;
 }
 
-static unsigned int get_filter_steerq(struct net_device *dev,
+static int get_filter_steerq(struct net_device *dev,
 				      struct ch_filter_specification *fs)
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
