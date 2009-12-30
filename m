From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/skfp/skfddi.c: use %pM to show MAC address
Date: Wed, 30 Dec 2009 15:17:13 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F672@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753489AbZL3URO@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

The only difference in the output is that the MAC address is
shown in the usual colon-separated hex notation.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index db216a7..4f17c9d 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -435,13 +435,7 @@ static  int skfp_driver_init(struct net_device *dev)
 		goto fail;
 	}
 	read_address(smc, NULL);
-	pr_debug(KERN_INFO "HW-Addr: %02x %02x %02x %02x %02x %02x\n",
-	       smc->hw.fddi_canon_addr.a[0],
-	       smc->hw.fddi_canon_addr.a[1],
-	       smc->hw.fddi_canon_addr.a[2],
-	       smc->hw.fddi_canon_addr.a[3],
-	       smc->hw.fddi_canon_addr.a[4],
-	       smc->hw.fddi_canon_addr.a[5]);
+	pr_debug(KERN_INFO "HW-Addr: %pM\n", smc->hw.fddi_canon_addr.a);
 	memcpy(dev->dev_addr, smc->hw.fddi_canon_addr.a, 6);
 
 	smt_reset_defaults(smc, 0);
@@ -890,15 +884,8 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 							  (struct fddi_addr *)dmi->dmi_addr, 
 							  1);
 
-					pr_debug(KERN_INFO "ENABLE MC ADDRESS:");
-					pr_debug(" %02x %02x %02x ",
-					       dmi->dmi_addr[0],
-					       dmi->dmi_addr[1],
-					       dmi->dmi_addr[2]);
-					pr_debug("%02x %02x %02x\n",
-					       dmi->dmi_addr[3],
-					       dmi->dmi_addr[4],
-					       dmi->dmi_addr[5]);
+					pr_debug(KERN_INFO "ENABLE MC ADDRESS: %pM\n",
+						dmi->dmi_addr);
 					dmi = dmi->next;
 				}	// for
  
