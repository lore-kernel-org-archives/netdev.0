From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/3] rose: do proto_unregister() on exit paths
Date: Wed, 28 Sep 2005 02:20:18 +0400
Message-ID: <20050927222018.GA25047@mipter.zuzino.mipt.ru>
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

 net/rose/af_rose.c |    2 ++
 1 file changed, 2 insertions(+)

--- linux-rose-000/net/rose/af_rose.c
+++ linux-rose-001/net/rose/af_rose.c
@@ -1475,24 +1475,26 @@ static int __init rose_proto_init(void)
 	int rc = proto_register(&rose_proto, 0);
 
 	if (rc != 0)
 		goto out;
 
 	rose_callsign = null_ax25_address;
 
 	if (rose_ndevs > 0x7FFFFFFF/sizeof(struct net_device *)) {
 		printk(KERN_ERR "ROSE: rose_proto_init - rose_ndevs parameter to large\n");
+		proto_unregister(&rose_proto);
 		return -1;
 	}
 
 	dev_rose = kmalloc(rose_ndevs * sizeof(struct net_device *), GFP_KERNEL);
 	if (dev_rose == NULL) {
 		printk(KERN_ERR "ROSE: rose_proto_init - unable to allocate device structure\n");
+		proto_unregister(&rose_proto);
 		return -1;
 	}
 
 	memset(dev_rose, 0x00, rose_ndevs * sizeof(struct net_device*));
 	for (i = 0; i < rose_ndevs; i++) {
 		struct net_device *dev;
 		char name[IFNAMSIZ];
 
 		sprintf(name, "rose%d", i);

