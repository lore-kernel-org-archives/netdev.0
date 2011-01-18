From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: rcu annotation fixup
Date: Tue, 18 Jan 2011 13:08:45 +0200
Message-ID: <20110118110845.GA11555@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When built with rcu checks enabled, vhost triggers
bogus warnings as vhost features are read without
dev->mutex sometimes.
Fixing it properly is not trivial as vhost.h does not
know which lockdep classes it will be used under.
Disable the warning by stubbing out the check for now.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.h |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 2af44b7..2d03a31 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -173,9 +173,7 @@ static inline int vhost_has_feature(struct vhost_dev *dev, int bit)
 {
 	unsigned acked_features;
 
-	acked_features =
-		rcu_dereference_index_check(dev->acked_features,
-					    lockdep_is_held(&dev->mutex));
+	acked_features = rcu_dereference_index_check(dev->acked_features, 1);
 	return acked_features & (1 << bit);
 }
 
-- 
1.7.3.2.91.g446ac
