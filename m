From: Amit Gud <amitg@calsoftinc.com>
Subject: [PATCH 9/18] drivers/net/ remove pci_find_{device, subsys}
Date: Mon, 14 Feb 2005 11:25:23 +0530
Message-ID: <200502141125.25185.amitg@calsoftinc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@lists.osdl.org, gud@eth.net
To: jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove deprecated pci_find_device and pci_find_subsys


AG
--
May the source be with you


Signed-off-by: Amit Gud <gud@eth.net>

diff -uprN orig/drivers/net/e1000/e1000_main.c linux-2.6.11-rc3/drivers/net/e1000/e1000_main.c
--- orig/drivers/net/e1000/e1000_main.c	2005-02-11 15:19:48.000000000 +0530
+++ linux-2.6.11-rc3/drivers/net/e1000/e1000_main.c	2005-02-14 02:02:48.000000000 +0530
@@ -2792,7 +2792,7 @@ e1000_notify_reboot(struct notifier_bloc
 	case SYS_DOWN:
 	case SYS_HALT:
 	case SYS_POWER_OFF:
-		while((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
+		while((pdev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
 			if(pci_dev_driver(pdev) == &e1000_driver)
 				e1000_suspend(pdev, 3);
 		}
diff -uprN orig/drivers/net/fc/iph5526.c linux-2.6.11-rc3/drivers/net/fc/iph5526.c
--- orig/drivers/net/fc/iph5526.c	2004-10-19 03:23:43.000000000 +0530
+++ linux-2.6.11-rc3/drivers/net/fc/iph5526.c	2005-02-14 02:02:55.000000000 +0530
@@ -3711,7 +3711,7 @@ int iph5526_detect(Scsi_Host_Template *t
 		fc[i] = NULL;
 
 	for (i = 0; clone_list[i].vendor_id != 0; i++)
-	while ((pdev = pci_find_device(clone_list[i].vendor_id, clone_list[i].device_id, pdev))) {
+	while ((pdev = pci_get_device(clone_list[i].vendor_id, clone_list[i].device_id, pdev))) {
 		unsigned short pci_command;
 		if (pci_enable_device(pdev))
 			continue;
diff -uprN orig/drivers/net/gt96100eth.c linux-2.6.11-rc3/drivers/net/gt96100eth.c
--- orig/drivers/net/gt96100eth.c	2005-02-11 15:19:48.000000000 +0530
+++ linux-2.6.11-rc3/drivers/net/gt96100eth.c	2005-02-14 02:07:09.000000000 +0530
@@ -615,9 +615,9 @@ static int gt96100_init_module(void)
 	/*
 	 * Stupid probe because this really isn't a PCI device
 	 */
-	if (!(pci = pci_find_device(PCI_VENDOR_ID_MARVELL,
+	if (!(pci = pci_get_device(PCI_VENDOR_ID_MARVELL,
 	                            PCI_DEVICE_ID_MARVELL_GT96100, NULL)) &&
-	    !(pci = pci_find_device(PCI_VENDOR_ID_MARVELL,
+	    !(pci = pci_get_device(PCI_VENDOR_ID_MARVELL,
 		                    PCI_DEVICE_ID_MARVELL_GT96100A, NULL))) {
 		printk(KERN_ERR __FILE__ ": GT96100 not found!\n");
 		return -ENODEV;
diff -uprN orig/drivers/net/ixgb/ixgb_main.c linux-2.6.11-rc3/drivers/net/ixgb/ixgb_main.c
--- orig/drivers/net/ixgb/ixgb_main.c	2005-02-11 15:19:48.000000000 +0530
+++ linux-2.6.11-rc3/drivers/net/ixgb/ixgb_main.c	2005-02-14 02:07:17.000000000 +0530
@@ -2087,7 +2087,7 @@ ixgb_notify_reboot(struct notifier_block
 	case SYS_DOWN:
 	case SYS_HALT:
 	case SYS_POWER_OFF:
-		while ((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
+		while ((pdev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
 			if (pci_dev_driver(pdev) == &ixgb_driver)
 				ixgb_suspend(pdev, 3);
 		}
diff -uprN orig/drivers/net/skfp/drvfbi.c linux-2.6.11-rc3/drivers/net/skfp/drvfbi.c
--- orig/drivers/net/skfp/drvfbi.c	2004-10-19 03:23:06.000000000 +0530
+++ linux-2.6.11-rc3/drivers/net/skfp/drvfbi.c	2005-02-14 02:07:23.000000000 +0530
@@ -1362,7 +1362,7 @@ int exist_board(struct s_smc *smc, int s
 		ven_id = OEMID(smc,0) + (OEMID(smc,1) << 8) ; 
 		dev_id = OEMID(smc,2) + (OEMID(smc,3) << 8) ; 
 		for (i = 0; i < slot; i++) {
-			if (pci_find_device(i,&smc->hw.pci_handle,
+			if (pci_get_device(i,&smc->hw.pci_handle,
 				dev_id,ven_id) != 0) {
 
 				found = FALSE ;
diff -uprN orig/drivers/net/sunhme.c linux-2.6.11-rc3/drivers/net/sunhme.c
--- orig/drivers/net/sunhme.c	2005-02-11 15:19:50.000000000 +0530
+++ linux-2.6.11-rc3/drivers/net/sunhme.c	2005-02-14 02:07:29.000000000 +0530
@@ -3312,7 +3312,7 @@ static int __init happy_meal_pci_probe(v
 	struct pci_dev *pdev = NULL;
 	int cards = 0;
 
-	while ((pdev = pci_find_device(PCI_VENDOR_ID_SUN,
+	while ((pdev = pci_get_device(PCI_VENDOR_ID_SUN,
 				       PCI_DEVICE_ID_SUN_HAPPYMEAL, pdev)) != NULL) {
 		if (pci_enable_device(pdev))
 			continue;
diff -uprN orig/drivers/net/tg3.c linux-2.6.11-rc3/drivers/net/tg3.c
--- orig/drivers/net/tg3.c	2005-02-11 15:19:50.000000000 +0530
+++ linux-2.6.11-rc3/drivers/net/tg3.c	2005-02-14 02:07:54.000000000 +0530
@@ -7825,15 +7825,15 @@ static int __devinit tg3_get_invariants(
 	 * every mailbox register write to force the writes to be
 	 * posted to the chip in order.
 	 */
-	if (pci_find_device(PCI_VENDOR_ID_INTEL,
+	if (pci_get_device(PCI_VENDOR_ID_INTEL,
 			    PCI_DEVICE_ID_INTEL_82801AA_8, NULL) ||
-	    pci_find_device(PCI_VENDOR_ID_INTEL,
+	    pci_get_device(PCI_VENDOR_ID_INTEL,
 			    PCI_DEVICE_ID_INTEL_82801AB_8, NULL) ||
-	    pci_find_device(PCI_VENDOR_ID_INTEL,
+	    pci_get_device(PCI_VENDOR_ID_INTEL,
 			    PCI_DEVICE_ID_INTEL_82801BA_11, NULL) ||
-	    pci_find_device(PCI_VENDOR_ID_INTEL,
+	    pci_get_device(PCI_VENDOR_ID_INTEL,
 			    PCI_DEVICE_ID_INTEL_82801BA_6, NULL) ||
-	    pci_find_device(PCI_VENDOR_ID_AMD,
+	    pci_get_device(PCI_VENDOR_ID_AMD,
 			    PCI_DEVICE_ID_AMD_FE_GATE_700C, NULL))
 		tp->tg3_flags |= TG3_FLAG_MBOX_WRITE_REORDER;
 
diff -uprN orig/drivers/net/wan/sdladrv.c linux-2.6.11-rc3/drivers/net/wan/sdladrv.c
--- orig/drivers/net/wan/sdladrv.c	2004-10-19 03:23:43.000000000 +0530
+++ linux-2.6.11-rc3/drivers/net/wan/sdladrv.c	2005-02-14 02:08:15.000000000 +0530
@@ -2032,7 +2032,7 @@ static int find_s514_adapter(sdlahw_t* h
  
        slot_no = hw->S514_slot_no;
   
-	while ((pci_dev = pci_find_device(V3_VENDOR_ID, V3_DEVICE_ID, pci_dev))
+	while ((pci_dev = pci_get_device(V3_VENDOR_ID, V3_DEVICE_ID, pci_dev))
         	!= NULL) {
                 
 		pci_read_config_word(pci_dev, PCI_SUBSYS_VENDOR_WORD,
@@ -2245,7 +2245,7 @@ static int pci_probe(sdlahw_t *hw)
  
        slot_no = 0;
   
-	while ((pci_dev = pci_find_device(V3_VENDOR_ID, V3_DEVICE_ID, pci_dev))
+	while ((pci_dev = pci_get_device(V3_VENDOR_ID, V3_DEVICE_ID, pci_dev))
         	!= NULL) {
 		
                 pci_read_config_word(pci_dev, PCI_SUBSYS_VENDOR_WORD,
