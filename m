From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rc1] prism54 Refix
	TRDY/RETRY_TIMEOUT
Date: Wed, 21 Jul 2004 08:58:00 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200407210858.00645.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_4Ph/AAp4awx81Gr"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_4Ph/AAp4awx81Gr
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-07-21 Margit Schubert-While <margitsw@t-online.de>

* Reintroduce pushing 0 into the TRDY_TIMEOUT and RETRY_TIMEOUT
  registers. Make this configurable with module parameter
  init_pcitm.

* We now have the ludicrous situation that some hardware setups
  require this (not even pushing 0xFF helps), whilst others
  don't care either way (the majority), and yet others bork
  if anything is pushed into these regs.
  If anybody can explain this (including Conexant :-) ), my ears
  are open.

Jeff, this patch together with the mgtframeptr patch from 07/15 are
pretty urgent.

Margit

--Boundary-00=_4Ph/AAp4awx81Gr
Content-Type: text/x-diff;
  charset="us-ascii";
  name="pciretry.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="pciretry.patch"

diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/islpci_hotplug.c linux-2.6.8-04/drivers/net/wireless/prism54/islpci_hotplug.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/islpci_hotplug.c	2004-07-01 07:23:52.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/islpci_hotplug.c	2004-07-20 19:07:30.000000000 +0200
@@ -36,6 +36,9 @@
 MODULE_DESCRIPTION("The Prism54 802.11 Wireless LAN adapter");
 MODULE_LICENSE("GPL");
 
+static int	init_pcitm = 0;
+module_param(init_pcitm, int, 0);
+
 /* In this order: vendor, device, subvendor, subdevice, class, class_mask,
  * driver_data 
  * If you have an update for this please contact prism54-devel@prism54.org 
@@ -292,14 +295,14 @@
 	 *
 	 * 	Writing zero to both these two registers will disable both timeouts and
 	 * 	*can* solve problems caused by devices that are slow to respond.
+	 *	Make this configurable - MSW
 	 */
-	/*	I am taking these out, we should not be poking around in the
-	 *	programmable timers - MSW
-	*/
-/*	Do not zero the programmable timers
-	pci_write_config_byte(pdev, 0x40, 0);
-	pci_write_config_byte(pdev, 0x41, 0);
-*/
+	if ( init_pcitm >= 0 ) {
+		pci_write_config_byte(pdev, 0x40, (u8)init_pcitm);
+		pci_write_config_byte(pdev, 0x41, (u8)init_pcitm);
+	} else {
+		printk(KERN_INFO "PCI TRDY/RETRY unchanged\n");
+	}
 
 	/* request the pci device I/O regions */
 	rvalue = pci_request_regions(pdev, DRV_NAME);

--Boundary-00=_4Ph/AAp4awx81Gr
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_4Ph/AAp4awx81Gr--
