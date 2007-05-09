From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 08/17] sky2: MIB counter overflow handling
Date: Tue, 08 May 2007 20:49:57 -0700
Message-ID: <20070509035029.405584018@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:58516 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1032351AbXEIEDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:03:45 -0400
Cc: Greg KH <greg@kroah.com>
Content-Disposition: inline; filename=sky2-mib-ov.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure that if we ever get a MIB counter overflow interrupt (normally
masked off), that it is cleared.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    6 ++++++
 1 file changed, 6 insertions(+)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 10:29:05.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 10:29:09.000000000 -0700
@@ -2332,6 +2332,12 @@ static void sky2_mac_intr(struct sky2_hw
 		printk(KERN_INFO PFX "%s: mac interrupt status 0x%x\n",
 		       dev->name, status);
 
+	if (status & GM_IS_RX_CO_OV)
+		gma_read16(hw, port, GM_RX_IRQ_SRC);
+
+	if (status & GM_IS_TX_CO_OV)
+		gma_read16(hw, port, GM_TX_IRQ_SRC);
+
 	if (status & GM_IS_RX_FF_OR) {
 		++sky2->net_stats.rx_fifo_errors;
 		sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_CLI_RX_FO);

--

