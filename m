From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 2/3] rose: return sane -E* from rose_proto_init()
Date: Wed, 28 Sep 2005 02:22:07 +0400
Message-ID: <20050927222207.GB25047@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Ralf Baechle <ralf@linux-mips.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/rose/af_rose.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

--- linux-rose-001/net/rose/af_rose.c
+++ linux-rose-002/net/rose/af_rose.c
@@ -1482,14 +1482,14 @@ static int __init rose_proto_init(void)
 	if (rose_ndevs > 0x7FFFFFFF/sizeof(struct net_device *)) {
 		printk(KERN_ERR "ROSE: rose_proto_init - rose_ndevs parameter to large\n");
 		proto_unregister(&rose_proto);
-		return -1;
+		return -EINVAL;
 	}
 
 	dev_rose = kmalloc(rose_ndevs * sizeof(struct net_device *), GFP_KERNEL);
 	if (dev_rose == NULL) {
 		printk(KERN_ERR "ROSE: rose_proto_init - unable to allocate device structure\n");
 		proto_unregister(&rose_proto);
-		return -1;
+		return -ENOMEM;
 	}
 
 	memset(dev_rose, 0x00, rose_ndevs * sizeof(struct net_device*));
@@ -1502,9 +1502,11 @@ static int __init rose_proto_init(void)
 				   name, rose_setup);
 		if (!dev) {
 			printk(KERN_ERR "ROSE: rose_proto_init - unable to allocate memory\n");
+			rc = -ENOMEM;
 			goto fail;
 		}
-		if (register_netdev(dev)) {
+		rc = register_netdev(dev);
+		if (rc) {
 			printk(KERN_ERR "ROSE: netdevice regeistration failed\n");
 			free_netdev(dev);
 			goto fail;
@@ -1539,7 +1541,7 @@ fail:
 	}
 	kfree(dev_rose);
 	proto_unregister(&rose_proto);
-	return -ENOMEM;
+	goto out;
 }
 module_init(rose_proto_init);
 

