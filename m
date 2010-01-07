From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/skfp/skfddi.c: use %pMF to show MAC address
Date: Thu, 7 Jan 2010 16:27:46 -0700
Message-ID: <201001071627.46569.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [206.15.93.42] ([206.15.93.42]:15148 "EHLO
	visionfs1.visionengravers.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750759Ab0AGX1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 18:27:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pMF kernel extension to display the MAC address.

The address will still be displayed in the FDDI Canonical format.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index db216a7..1f9698c 100644
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
+	pr_debug(KERN_INFO "HW-Addr: %pMF\n", smc->hw.fddi_canon_addr.a);
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
+					pr_debug(KERN_INFO "ENABLE MC ADDRESS: %pMF\n",
+						dmi->dmi_addr);
 					dmi = dmi->next;
 				}	// for
 
