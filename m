From: Gregory Haskins <ghaskins@novell.com>
Subject: [NET PATCH 4/9] venet: report actual used descriptor size
Date: Wed, 14 Oct 2009 11:59:07 -0400
Message-ID: <20091014155906.18864.23409.stgit@dev.haskins.net>
References: <20091014154457.18864.28382.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20091014154457.18864.28382.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should reduce wasted effort copying parts of the descriptor
which are not in use, since the descriptors are typically pre-allocated
to their maximum size.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 drivers/net/vbus-enet.c |    2 ++
 include/linux/venet.h   |    3 +++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/vbus-enet.c b/drivers/net/vbus-enet.c
index b3e9695..63237f3 100644
--- a/drivers/net/vbus-enet.c
+++ b/drivers/net/vbus-enet.c
@@ -582,6 +582,8 @@ vbus_enet_tx_start(struct sk_buff *skb, struct net_device *dev)
 			iov->ptr = (u64)sg_phys(sg);
 		}
 
+		iter.desc->len = (u64)VSG_DESC_SIZE(vsg->count);
+
 	} else {
 		/*
 		 * non scatter-gather mode: simply put the skb right onto the
diff --git a/include/linux/venet.h b/include/linux/venet.h
index 57aeddd..53b6958 100644
--- a/include/linux/venet.h
+++ b/include/linux/venet.h
@@ -76,6 +76,9 @@ struct venet_sg {
 	struct venet_iov iov[1];
 };
 
+#define VSG_DESC_SIZE(count) (sizeof(struct venet_sg) + \
+			      sizeof(struct venet_iov) * ((count) - 1))
+
 #define VENET_FUNC_LINKUP    0
 #define VENET_FUNC_LINKDOWN  1
 #define VENET_FUNC_MACQUERY  2

