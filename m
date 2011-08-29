From: Joe Perches <joe@perches.com>
Subject: [PATCH 13/24] netrom: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:32 -0700
Message-ID: <cb2e0e97b3600c4d4ca3332e6b036766985ee389.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
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
 net/netrom/af_netrom.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 732152f..72801b28 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1405,10 +1405,8 @@ static int __init nr_proto_init(void)
 	}
 
 	dev_nr = kzalloc(nr_ndevs * sizeof(struct net_device *), GFP_KERNEL);
-	if (dev_nr == NULL) {
-		printk(KERN_ERR "NET/ROM: nr_proto_init - unable to allocate device array\n");
+	if (dev_nr == NULL)
 		return -1;
-	}
 
 	for (i = 0; i < nr_ndevs; i++) {
 		char name[IFNAMSIZ];
@@ -1416,10 +1414,8 @@ static int __init nr_proto_init(void)
 
 		sprintf(name, "nr%d", i);
 		dev = alloc_netdev(0, name, nr_setup);
-		if (!dev) {
-			printk(KERN_ERR "NET/ROM: nr_proto_init - unable to allocate device structure\n");
+		if (!dev)
 			goto fail;
-		}
 
 		dev->base_addr = i;
 		if (register_netdev(dev)) {
-- 
1.7.6.405.gc1be0
