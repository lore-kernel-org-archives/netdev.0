From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH -next] netxen: fix builds for SYSFS=n or MODULES=n
Date: Tue, 27 Oct 2009 15:09:24 -0700
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0B8903CB@AVEXMB1.qlogic.org>
References: <20091026172104.205f15af.sfr@canb.auug.org.au>
 <20091026150945.3f35a811.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091026150945.3f35a811.randy.dunlap@oracle.com>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, seems like I am keeping you busy with the build errors.
Thanks for fixing it again (may be I need to setup all different build configs).

Acked-by: Dhananjay Phadke <dhananjay@netxen.com>

-----Original Message-----
From: Randy Dunlap [mailto:randy.dunlap@oracle.com] 
Sent: Monday, October 26, 2009 3:10 PM
To: Stephen Rothwell; netdev
Cc: linux-next@vger.kernel.org; LKML; davem@davemloft.net; Dhananjay Phadke
Subject: [PATCH -next] netxen: fix builds for SYSFS=n or MODULES=n

From: Randy Dunlap <randy.dunlap@oracle.com>

When CONFIG_MODULES=n:
drivers/net/netxen/netxen_nic_main.c:2751: error: dereferencing pointer to incomplete type
drivers/net/netxen/netxen_nic_main.c:2764: error: dereferencing pointer to incomplete type

Also needs addition of <linux/sysfs.h> for sysfs function prototypes or
stubs when CONFIG_SYSFS=n.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/netxen/netxen_nic_main.c |    9 +++++++++
 1 file changed, 9 insertions(+)

--- linux-next-20091026.orig/drivers/net/netxen/netxen_nic_main.c
+++ linux-next-20091026/drivers/net/netxen/netxen_nic_main.c
@@ -34,6 +34,7 @@
 #include <net/ip.h>
 #include <linux/ipv6.h>
 #include <linux/inetdevice.h>
+#include <linux/sysfs.h>
 
 MODULE_DESCRIPTION("NetXen Multi port (1/10) Gigabit Network Driver");
 MODULE_LICENSE("GPL");
@@ -2500,6 +2501,7 @@ static struct bin_attribute bin_attr_mem
 	.write = netxen_sysfs_write_mem,
 };
 
+#ifdef CONFIG_MODULES
 static ssize_t
 netxen_store_auto_fw_reset(struct module_attribute *mattr,
 		struct module *mod, const char *buf, size_t count)
@@ -2534,6 +2536,7 @@ static struct module_attribute mod_attr_
 	.show = netxen_show_auto_fw_reset,
 	.store = netxen_store_auto_fw_reset,
 };
+#endif
 
 static void
 netxen_create_sysfs_entries(struct netxen_adapter *adapter)
@@ -2739,7 +2742,9 @@ static struct pci_driver netxen_driver =
 
 static int __init netxen_init_module(void)
 {
+#ifdef CONFIG_MODULES
 	struct module *mod = THIS_MODULE;
+#endif
 
 	printk(KERN_INFO "%s\n", netxen_nic_driver_string);
 
@@ -2748,9 +2753,11 @@ static int __init netxen_init_module(voi
 	register_inetaddr_notifier(&netxen_inetaddr_cb);
 #endif
 
+#ifdef CONFIG_MODULES
 	if (sysfs_create_file(&mod->mkobj.kobj, &mod_attr_fw_reset.attr))
 		printk(KERN_ERR "%s: Failed to create auto_fw_reset "
 				"sysfs entry.", netxen_nic_driver_name);
+#endif
 
 	return pci_register_driver(&netxen_driver);
 }
@@ -2759,9 +2766,11 @@ module_init(netxen_init_module);
 
 static void __exit netxen_exit_module(void)
 {
+#ifdef CONFIG_MODULES
 	struct module *mod = THIS_MODULE;
 
 	sysfs_remove_file(&mod->mkobj.kobj, &mod_attr_fw_reset.attr);
+#endif
 
 	pci_unregister_driver(&netxen_driver);
 
