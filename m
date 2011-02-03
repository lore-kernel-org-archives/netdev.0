From: Anders Berggren <anders@halon.se>
Subject: [PATCH] fixing hw timestamping in igb
Date: Thu, 3 Feb 2011 11:39:27 +0100
Message-ID: <9D02360A-8016-4BCB-B14A-DAFE22EF558E@halon.se>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Patrick Ohly <patrick.ohly@intel.com>
To: John Ronciak <john.ronciak@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hardware timestamping for Intel 82580 didn't work in either 2.6.36 or 2.6.37. Comparing it to Intel's igb-2.4.12 I found that the timecounter_init clock/counter initialization was done too early. 

Anders Berggren
Halon Security

lab-slang-1:~# diff -u linux-2.6.37/drivers/net/igb/igb_main.c linux/drivers/net/igb/igb_main.c
--- linux-2.6.37/drivers/net/igb/igb_main.c	2011-02-03 10:02:53.000000000 +0100
+++ linux/drivers/net/igb/igb_main.c	2011-02-03 10:12:40.000000000 +0100
@@ -98,6 +98,7 @@
 static void igb_setup_mrqc(struct igb_adapter *);
 static int igb_probe(struct pci_dev *, const struct pci_device_id *);
 static void __devexit igb_remove(struct pci_dev *pdev);
+static void igb_init_hw_timer(struct igb_adapter *adapter);
 static int igb_sw_init(struct igb_adapter *);
 static int igb_open(struct net_device *);
 static int igb_close(struct net_device *);
@@ -1987,6 +1988,10 @@
 	}
 
 #endif
+
+	/* do hw tstamp init after resetting */ 
+	igb_init_hw_timer(adapter);
+
 	dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n");
 	/* print bus type/speed/width info */
 	dev_info(&pdev->dev, "%s: (PCIe:%s:%s) %pM\n",
@@ -2301,7 +2306,6 @@
 		return -ENOMEM;
 	}
 
-	igb_init_hw_timer(adapter);
 	igb_probe_vfs(adapter);
 
 	/* Explicitly disable IRQ since the NIC can be in any state. */


------------------------------------------------------------------------------
Special Offer-- Download ArcSight Logger for FREE (a $49 USD value)!
Finally, a world-class log management solution at an even better price-free!
Download using promo code Free_Logger_4_Dev2Dev. Offer expires 
February 28th, so secure your free ArcSight Logger TODAY! 
http://p.sf.net/sfu/arcsight-sfd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
