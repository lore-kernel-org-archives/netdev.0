From: Pavel Machek <pavel@ucw.cz>
Subject: [-mm] ipw2100: small cleanups
Date: Wed, 8 Jun 2005 16:20:47 +0200
Message-ID: <20050608142047.GA2310@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Netdev list <netdev@oss.sgi.com>,
        Andrew Morton <akpm@zip.com.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix few typos/thinkos in ipw, remove ugly macro (it is commented
around, anyway), and fix types passed to pci_set_power_state.


--- middle-mm//drivers/net/wireless/ipw2100.c	2005-06-08 16:15:23.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2100.c	2005-06-08 16:16:27.000000000 +0200
@@ -916,7 +916,7 @@
 }
 
 /*********************************************************************
-    Procedure   :   ipw2100_ipw2100_download_firmware
+    Procedure   :   ipw2100_download_firmware
     Purpose     :   Initiaze adapter after power on.
                     The sequence is:
                     1. assert s/w reset first!
@@ -1150,7 +1150,6 @@
  */
 static int ipw2100_start_adapter(struct ipw2100_priv *priv)
 {
-#define IPW_WAIT_FW_INIT_COMPLETE_DELAY (40 * HZ / 1000)
 	int i;
 	u32 inta, inta_mask, gpio;
 
@@ -1185,7 +1184,7 @@
 	i = 5000;
 	do {
   		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(IPW_WAIT_FW_INIT_COMPLETE_DELAY);
+		schedule_timeout(40 * HZ / 1000);
 		/* Todo... wait for sync command ... */
 
 		read_register(priv->net_dev, IPW_REG_INTA, &inta);
@@ -1641,7 +1640,7 @@
 	} else
 		priv->status |= STATUS_POWERED;
 
-	/* Load the firmeware, start the clocks, etc. */
+	/* Load the firmware, start the clocks, etc. */
 	if (ipw2100_start_adapter(priv)) {
 	       	printk(KERN_ERR DRV_NAME ": %s: Failed to start the firmware.\n",
 				priv->net_dev->name);
@@ -5679,7 +5678,7 @@
 	if ((val & 0x0000ff00) != 0)
 		pci_write_config_dword(pci_dev, 0x40, val & 0xffff00ff);
 
-	pci_set_power_state(pci_dev, 0);
+	pci_set_power_state(pci_dev, PCI_D0);
 
 	if (!ipw2100_hw_is_adapter_in_system(dev)) {
 		printk(KERN_WARNING DRV_NAME
@@ -7206,7 +7205,7 @@
         ipw2100_wx_set_wap,       /* SIOCSIWAP */
         ipw2100_wx_get_wap,       /* SIOCGIWAP */
         NULL,                     /* -- hole -- */
-        NULL,                     /* SIOCGIWAPLIST -- depricated */
+        NULL,                     /* SIOCGIWAPLIST -- deprecated */
         ipw2100_wx_set_scan,      /* SIOCSIWSCAN */
         ipw2100_wx_get_scan,      /* SIOCGIWSCAN */
         ipw2100_wx_set_essid,     /* SIOCSIWESSID */
