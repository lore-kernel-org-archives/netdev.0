From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/atm/fore200e.c: use %pM to show MAC address
Date: Wed, 30 Dec 2009 14:38:25 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F663@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og106.obsmtp.com ([64.18.1.191]:58870 "HELO
	exprod6og106.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753212AbZL3Ti0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 14:38:26 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index bc53fed..f7d6eba 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2064,12 +2064,10 @@ fore200e_get_esi(struct fore200e* fore200e)
 	return -EBUSY;
     }
 	
-    printk(FORE200E "device %s, rev. %c, S/N: %d, ESI: %02x:%02x:%02x:%02x:%02x:%02x\n", 
+    printk(FORE200E "device %s, rev. %c, S/N: %d, ESI: %pM\n",
 	   fore200e->name, 
 	   (prom->hw_revision & 0xFF) + '@',    /* probably meaningless with SBA boards */
-	   prom->serial_number & 0xFFFF,
-	   prom->mac_addr[ 2 ], prom->mac_addr[ 3 ], prom->mac_addr[ 4 ],
-	   prom->mac_addr[ 5 ], prom->mac_addr[ 6 ], prom->mac_addr[ 7 ]);
+	   prom->serial_number & 0xFFFF, &prom->mac_addr[2]);
 	
     for (i = 0; i < ESI_LEN; i++) {
 	fore200e->esi[ i ] = fore200e->atm_dev->esi[ i ] = prom->mac_addr[ i + 2 ];
@@ -2845,13 +2843,12 @@ fore200e_proc_read(struct atm_dev *dev, loff_t* pos, char* page)
 		"   interrupt line:\t\t%s\n"
 		"   physical base address:\t0x%p\n"
 		"   virtual base address:\t0x%p\n"
-		"   factory address (ESI):\t%02x:%02x:%02x:%02x:%02x:%02x\n"
+		"   factory address (ESI):\t%pM\n"
 		"   board serial number:\t\t%d\n\n",
 		fore200e_irq_itoa(fore200e->irq),
 		(void*)fore200e->phys_base,
 		fore200e->virt_base,
-		fore200e->esi[0], fore200e->esi[1], fore200e->esi[2],
-		fore200e->esi[3], fore200e->esi[4], fore200e->esi[5],
+		fore200e->esi,
 		fore200e->esi[4] * 256 + fore200e->esi[5]);
 
 	return len; 
