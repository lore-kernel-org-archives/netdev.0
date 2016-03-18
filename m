From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] net: consolidate lock/unlock into unlock_wait
Date: Fri, 18 Mar 2016 10:32:05 +0100
Message-ID: <1458293525-16842-1-git-send-email-hofrat@osadl.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The spin_lock()/spin_unlock() is synchronizing on the adapter->work_lock
as the comment also suggests, which is equivalent to spin_unlock_wait()
but the later should be more efficient.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Problem located by coccinelle spatch

Patch was compile tested with: x86_64_defconfig + CONFIG_CHELSIO_T1=m

Patch is against linux-next (localversion-next is next-20160318)

 drivers/net/ethernet/chelsio/cxgb/cxgb2.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index f5f1b0b..c5a38dc 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -282,8 +282,8 @@ static int cxgb_close(struct net_device *dev)
 	    !(adapter->open_device_map & PORT_MASK)) {
 		/* Stop statistics accumulation. */
 		smp_mb__after_atomic();
-		spin_lock(&adapter->work_lock);   /* sync with update task */
-		spin_unlock(&adapter->work_lock);
+		/* sync with update task */
+		spin_unlock_wait(&adapter->work_lock);
 		cancel_mac_stats_update(adapter);
 	}
 
-- 
2.1.4
