From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/24] can: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:26 -0700
Message-ID: <d2773db0709a09bfe6d43a28ba1323c5d3f9a76b.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/can/af_can.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index b9efa94..11300be 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -770,11 +770,9 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
 
 		/* create new dev_rcv_lists for this device */
 		d = kzalloc(sizeof(*d), GFP_KERNEL);
-		if (!d) {
-			printk(KERN_ERR
-			       "can: allocation of receive list failed\n");
+		if (!d)
 			return NOTIFY_DONE;
-		}
+
 		BUG_ON(dev->ml_priv);
 		dev->ml_priv = d;
 
-- 
1.7.6.405.gc1be0
