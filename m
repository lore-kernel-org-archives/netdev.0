From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] switch comx over to initcalls
Date: Sun, 18 May 2003 19:04:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030518190423.A28834@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The link order already is the same as the old init order.  Note that the
drivers are still full of crap, I don't have the hardware so I refuse to
poke deeper into the shite..


--- 1.10/drivers/net/setup.c	Sat May 10 09:07:26 2003
+++ edited/drivers/net/setup.c	Sat May 17 21:12:09 2003
@@ -16,7 +16,6 @@
 extern int fec_enet_init(void); 
 extern int sdla_setup(void); 
 extern int sdla_c_setup(void); 
-extern int comx_init(void);
 extern int lmc_setup(void);
 
 extern int madgemc_probe(void);
@@ -52,10 +51,6 @@
 #if defined(CONFIG_FEC_ENET)
         {fec_enet_init, 0},
 #endif
-#if defined(CONFIG_COMX)
-	{comx_init, 0},
-#endif
-	 
 #if defined(CONFIG_LANMEDIA)
 	{lmc_setup, 0},
 #endif
===== drivers/net/wan/comx-hw-comx.c 1.10 vs edited =====
--- 1.10/drivers/net/wan/comx-hw-comx.c	Mon Apr 28 05:36:20 2003
+++ edited/drivers/net/wan/comx-hw-comx.c	Sat May 17 20:35:54 2003
@@ -1427,24 +1427,20 @@
 	NULL
 };
 
-#ifdef MODULE
-#define comx_hw_comx_init init_module
-#endif
-
-int __init comx_hw_comx_init(void)
+static int __init comx_hw_comx_init(void)
 {
 	comx_register_hardware(&comx_hw);
 	comx_register_hardware(&cmx_hw);
 	comx_register_hardware(&hicomx_hw);
-	memset(memory_used, 0, sizeof(memory_used));
 	return 0;
 }
 
-#ifdef MODULE
-void cleanup_module(void)
+static void __exit comx_hw_comx_exit(void)
 {
 	comx_unregister_hardware("comx");
 	comx_unregister_hardware("cmx");
 	comx_unregister_hardware("hicomx");
 }
-#endif
+
+module_init(comx_hw_comx_init);
+module_exit(comx_hw_comx_exit);
===== drivers/net/wan/comx-hw-locomx.c 1.6 vs edited =====
--- 1.6/drivers/net/wan/comx-hw-locomx.c	Thu Nov 21 23:06:12 2002
+++ edited/drivers/net/wan/comx-hw-locomx.c	Sat May 17 20:37:07 2003
@@ -479,20 +479,16 @@
 	NULL
 };
 	
-#ifdef MODULE
-#define comx_hw_locomx_init init_module
-#endif
-
-int __init comx_hw_locomx_init(void)
+static int __init comx_hw_locomx_init(void)
 {
 	comx_register_hardware(&locomx_hw);
 	return 0;
 }
 
-#ifdef MODULE
-void cleanup_module(void)
+static void __exit comx_hw_locomx_exit(void)
 {
 	comx_unregister_hardware("locomx");
-	return;
 }
-#endif
+
+module_init(comx_hw_locomx_init);
+module_exit(comx_hw_locomx_exit);
===== drivers/net/wan/comx-hw-mixcom.c 1.9 vs edited =====
--- 1.9/drivers/net/wan/comx-hw-mixcom.c	Mon Apr 28 05:36:20 2003
+++ edited/drivers/net/wan/comx-hw-mixcom.c	Sat May 17 20:38:51 2003
@@ -944,21 +944,15 @@
 	NULL
 };
 	
-/* Module management */
-
-#ifdef MODULE
-#define comx_hw_mixcom_init init_module
-#endif
-
-int __init comx_hw_mixcom_init(void)
+static int __init comx_hw_mixcom_init(void)
 {
-	return(comx_register_hardware(&mixcomhw));
+	return comx_register_hardware(&mixcomhw);
 }
 
-#ifdef MODULE
-void
-cleanup_module(void)
+static void __exit comx_hw_mixcom_exit(void)
 {
 	comx_unregister_hardware("mixcom");
 }
-#endif
+
+module_init(comx_hw_mixcom_init);
+module_exit(comx_hw_mixcom_exit);
===== drivers/net/wan/comx-proto-fr.c 1.10 vs edited =====
--- 1.10/drivers/net/wan/comx-proto-fr.c	Thu Nov 21 23:06:12 2002
+++ edited/drivers/net/wan/comx-proto-fr.c	Sat May 17 20:46:48 2003
@@ -988,11 +988,7 @@
 	.hw_dump	= dlci_dump, 
 };
 
-#ifdef MODULE
-#define comx_proto_fr_init init_module
-#endif
-
-int __init comx_proto_fr_init(void)
+static int __init comx_proto_fr_init(void)
 {
 	int ret; 
 
@@ -1005,12 +1001,12 @@
 	return comx_register_protocol(&fr_slave_protocol);
 }
 
-#ifdef MODULE
-void cleanup_module(void)
+static void __exit comx_proto_fr_exit(void)
 {
 	comx_unregister_hardware(fr_dlci.name);
 	comx_unregister_protocol(fr_master_protocol.name);
 	comx_unregister_protocol(fr_slave_protocol.name);
 }
-#endif /* MODULE */
 
+module_init(comx_proto_fr_init);
+module_exit(comx_proto_fr_exit);
===== drivers/net/wan/comx-proto-lapb.c 1.5 vs edited =====
--- 1.5/drivers/net/wan/comx-proto-lapb.c	Tue Feb  5 08:45:17 2002
+++ edited/drivers/net/wan/comx-proto-lapb.c	Sat May 17 20:45:55 2003
@@ -523,7 +523,7 @@
 	NULL 
 };
 
-int __init comx_proto_lapb_init(void)
+static int __init comx_proto_lapb_init(void)
 {
 	int ret;
 
@@ -539,9 +539,7 @@
 	comx_unregister_protocol(comx25_protocol.name);
 }
 
-#ifdef MODULE
 module_init(comx_proto_lapb_init);
-#endif
 module_exit(comx_proto_lapb_exit);
 
 MODULE_LICENSE("GPL");
===== drivers/net/wan/comx-proto-ppp.c 1.4 vs edited =====
--- 1.4/drivers/net/wan/comx-proto-ppp.c	Wed May 22 20:16:37 2002
+++ edited/drivers/net/wan/comx-proto-ppp.c	Sat May 17 20:45:20 2003
@@ -247,26 +247,24 @@
 	NULL 
 };
 
-
-#ifdef MODULE
-#define comx_proto_ppp_init init_module
-#endif
-
-int __init comx_proto_ppp_init(void)
+static int __init comx_proto_ppp_init(void)
 {
 	int ret;
 
-	if(0!=(ret=comx_register_protocol(&hdlc_protocol))) {
-		return ret;
+	ret = comx_register_protocol(&hdlc_protocol);
+	if (!ret) {
+		ret = comx_register_protocol(&syncppp_protocol);
+		if (ret)
+			comx_unregister_protocol(hdlc_protocol.name);
 	}
-	return comx_register_protocol(&syncppp_protocol);
+	return ret;
 }
 
-#ifdef MODULE
-void cleanup_module(void)
+static void __exit comx_proto_ppp_exit(void)
 {
 	comx_unregister_protocol(syncppp_protocol.name);
 	comx_unregister_protocol(hdlc_protocol.name);
 }
-#endif /* MODULE */
 
+module_init(comx_proto_ppp_init);
+module_exit(comx_proto_ppp_exit);
===== drivers/net/wan/comx.c 1.17 vs edited =====
--- 1.17/drivers/net/wan/comx.c	Sat May 17 21:39:13 2003
+++ edited/drivers/net/wan/comx.c	Sat May 17 20:48:05 2003
@@ -81,15 +81,6 @@
 MODULE_DESCRIPTION("Common code for the COMX synchronous serial adapters");
 MODULE_LICENSE("GPL");
 
-extern int comx_hw_comx_init(void);
-extern int comx_hw_locomx_init(void);
-extern int comx_hw_mixcom_init(void);
-extern int comx_proto_hdlc_init(void);
-extern int comx_proto_ppp_init(void);
-extern int comx_proto_syncppp_init(void);
-extern int comx_proto_lapb_init(void);
-extern int comx_proto_fr_init(void);
-
 static struct comx_hardware *comx_channels = NULL;
 static struct comx_protocol *comx_lines = NULL;
 
@@ -1078,11 +1069,7 @@
 	return -1;
 }
 
-#ifdef MODULE
-#define comx_init init_module
-#endif
-
-int __init comx_init(void)
+static int __init comx_init(void)
 {
 	struct proc_dir_entry *new_file;
 
@@ -1115,42 +1102,18 @@
 
 	printk(KERN_INFO "COMX: driver version %s (C) 1995-1999 ITConsult-Pro Co. <info@itc.hu>\n", 
 		VERSION);
-
-#ifndef MODULE
-#ifdef CONFIG_COMX_HW_COMX
-	comx_hw_comx_init();
-#endif
-#ifdef CONFIG_COMX_HW_LOCOMX
-	comx_hw_locomx_init();
-#endif
-#ifdef CONFIG_COMX_HW_MIXCOM
-	comx_hw_mixcom_init();
-#endif
-#ifdef CONFIG_COMX_PROTO_HDLC
-	comx_proto_hdlc_init();
-#endif
-#ifdef CONFIG_COMX_PROTO_PPP
-	comx_proto_ppp_init();
-#endif
-#ifdef CONFIG_COMX_PROTO_LAPB
-	comx_proto_lapb_init();
-#endif
-#ifdef CONFIG_COMX_PROTO_FR
-	comx_proto_fr_init();
-#endif
-#endif
-
 	return 0;
 }
 
-#ifdef MODULE
-void cleanup_module(void)
+static void __exit comx_exit(void)
 {
 	remove_proc_entry(FILENAME_HARDWARELIST, comx_root_dir);
 	remove_proc_entry(FILENAME_PROTOCOLLIST, comx_root_dir);
 	remove_proc_entry(comx_root_dir->name, &proc_root);
 }
-#endif
+
+module_init(comx_init);
+module_exit(comx_exit);
 
 EXPORT_SYMBOL(comx_register_hardware);
 EXPORT_SYMBOL(comx_unregister_hardware);
