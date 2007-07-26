From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.22 2/3]S2io: Fix crash when resetting adapter
Date: 25 Jul 2007 19:40:33 -0700
Message-ID: <1185417633.21141.45.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, ram.vepa@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:56115 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239AbXGZApc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 20:45:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Removed the call to pci_set_power_state to reset the adapter as it was resulting
  in system crash on some platforms.

(Resending; Removed HTML sections in the patch)

Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
---
diff -Nurp 2.0.24.1P1/drivers/net/s2io.c 2.0.24.1P2/drivers/net/s2io.c
--- 2.0.24.1P1/drivers/net/s2io.c	2007-07-20 16:16:01.000000000 -0700
+++ 2.0.24.1P2/drivers/net/s2io.c	2007-07-20 16:26:13.000000000 -0700
@@ -3382,23 +3382,8 @@ static void s2io_reset(struct s2io_nic *
 	/* Back up  the PCI-X CMD reg, dont want to lose MMRBC, OST settings */
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER, &(pci_cmd));
 
-	if (sp->device_type == XFRAME_II_DEVICE) {
-		int ret;
-		ret = pci_set_power_state(sp->pdev, 3);
-		if (!ret)
-			ret = pci_set_power_state(sp->pdev, 0);
-		else {
-			DBG_PRINT(ERR_DBG,"%s PME based SW_Reset failed!\n",
-					__FUNCTION__);
-			goto old_way;
-		}
-		msleep(20);
-		goto new_way;
-	}
-old_way:
 	val64 = SW_RESET_ALL;
 	writeq(val64, &bar0->sw_reset);
-new_way:
 	if (strstr(sp->product_name, "CX4")) {
 		msleep(750);
 	}



