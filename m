From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 18/33] net: arcdev - label alloc_arcdev names
Date: Thu, 10 Jul 2014 10:17:23 +0200
Message-ID: <1404980258-30853-19-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let the drivers pass in the name assign type. They all get the name as a module
parameter.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/arcnet/arc-rimi.c     | 2 +-
 drivers/net/arcnet/arcnet.c       | 8 ++++++--
 drivers/net/arcnet/com20020-isa.c | 2 +-
 drivers/net/arcnet/com20020-pci.c | 2 +-
 drivers/net/arcnet/com20020_cs.c  | 2 +-
 drivers/net/arcnet/com90io.c      | 2 +-
 drivers/net/arcnet/com90xx.c      | 2 +-
 include/linux/arcdevice.h         | 3 ++-
 8 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index b8b4c7b..c6fc1ce 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -337,7 +337,7 @@ static int __init arc_rimi_init(void)
 {
 	struct net_device *dev;
 
-	dev = alloc_arcdev(device);
+	dev = alloc_arcdev(device, NET_NAME_USER);
 	if (!dev)
 		return -ENOMEM;
 
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 3b790de..710fe54 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -341,12 +341,16 @@ static void arcdev_setup(struct net_device *dev)
 
 }
 
-struct net_device *alloc_arcdev(const char *name)
+struct net_device *alloc_arcdev(const char *name, unsigned char name_assign_type)
 {
 	struct net_device *dev;
 
+	if (name && !*name)
+		name = NULL;
+
 	dev = alloc_netdev(sizeof(struct arcnet_local),
-			   name && *name ? name : "arc%d", NET_NAME_UNKNOWN,
+			   name ? name : "arc%d",
+			   name ? name_assign_type : NET_NAME_ENUM,
 			   arcdev_setup);
 	if(dev) {
 		struct arcnet_local *lp = netdev_priv(dev);
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index 45c61a2..4b48598 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -144,7 +144,7 @@ static int __init com20020_init(void)
 	struct net_device *dev;
 	struct arcnet_local *lp;
 
-	dev = alloc_arcdev(device);
+	dev = alloc_arcdev(device, NET_NAME_USER);
 	if (!dev)
 		return -ENOMEM;
 
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index cbc44f5..b1d0dc7 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -69,7 +69,7 @@ static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *i
 
 	if (pci_enable_device(pdev))
 		return -EIO;
-	dev = alloc_arcdev(device);
+	dev = alloc_arcdev(device, NET_NAME_USER);
 	if (!dev)
 		return -ENOMEM;
 
diff --git a/drivers/net/arcnet/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
index 326a612..de09df0 100644
--- a/drivers/net/arcnet/com20020_cs.c
+++ b/drivers/net/arcnet/com20020_cs.c
@@ -129,7 +129,7 @@ static int com20020_probe(struct pcmcia_device *p_dev)
     if (!info)
 	goto fail_alloc_info;
 
-    dev = alloc_arcdev("");
+    dev = alloc_arcdev("", NET_NAME_UNKNOWN);
     if (!dev)
 	goto fail_alloc_dev;
 
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 487d780..f3b2938 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -394,7 +394,7 @@ static int __init com90io_init(void)
 	struct net_device *dev;
 	int err;
 
-	dev = alloc_arcdev(device);
+	dev = alloc_arcdev(device, NET_NAME_USER);
 	if (!dev)
 		return -ENOMEM;
 
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index b80fbe4..875efbd 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -463,7 +463,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 	int mirror_size;
 
 	/* allocate struct net_device */
-	dev = alloc_arcdev(device);
+	dev = alloc_arcdev(device, NET_NAME_USER);
 	if (!dev) {
 		BUGMSG2(D_NORMAL, "com90xx: Can't allocate device!\n");
 		iounmap(p);
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index 7216b0d..1e9a473 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -334,7 +334,8 @@ void arcnet_dump_skb(struct net_device *dev, struct sk_buff *skb, char *desc);
 
 void arcnet_unregister_proto(struct ArcProto *proto);
 irqreturn_t arcnet_interrupt(int irq, void *dev_id);
-struct net_device *alloc_arcdev(const char *name);
+struct net_device *alloc_arcdev(const char *name,
+				unsigned char name_assgin_type);
 
 int arcnet_open(struct net_device *dev);
 int arcnet_close(struct net_device *dev);
-- 
1.9.3
