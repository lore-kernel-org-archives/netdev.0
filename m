From: xiaohui.xin@intel.com
Subject: [PATCH v15 10/17]If device is in zero-copy mode first, bonding will fail.
Date: Tue,  9 Nov 2010 17:03:15 +0800
Message-ID: <e7f506c6f09e8c7f3279e1bbc95d02013b2f6f1a.1289280886.git.xiaohui.xin@intel.com>
References: <1289293402-4791-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289293402-4791-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1289280885.git.xiaohui.xin@intel.com>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1289280885.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

If device is in this zero-copy mode first, we cannot handle this,
so fail it. This patch is for this.

If bonding is created first, and one of the device will be in zero-copy
mode, this will be handled by mp device. It will first check if all the
slaves have the zero-copy capability. If no, fail too. Otherwise make
all the slaves in zero-copy mode.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
---
 drivers/net/bonding/bond_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3b16f62..dfb6a2c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1428,6 +1428,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			   bond_dev->name);
 	}
 
+	/* if the device is in zero-copy mode before bonding, fail it. */
+	if (dev_is_mpassthru(slave_dev))
+		return -EBUSY;
+
 	/* already enslaved */
 	if (slave_dev->flags & IFF_SLAVE) {
 		pr_debug("Error, Device was already enslaved\n");
-- 
1.7.3
