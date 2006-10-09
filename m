From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: set lower pause threshold to prevent overrun
Date: Mon, 9 Oct 2006 15:49:27 -0700
Message-ID: <20061009154927.51aac742@freekitty>
References: <20061009144038.6d3a93d6@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18126 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750719AbWJIWuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 18:50:24 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061009144038.6d3a93d6@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adjust the pause threshold on slower systems to keep from getting overrun.
Since FIFO is 2K bytes, don't send XON pause until there is space for a full
frame.

---
 drivers/net/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- sky2.orig/drivers/net/sky2.c	2006-10-09 15:43:51.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-09 15:43:52.000000000 -0700
@@ -683,7 +683,7 @@
 	sky2_write16(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_OPER_ON);
 
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
-		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
+		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 512/8);
 		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
 		if (hw->dev[port]->mtu > ETH_DATA_LEN) {
 			/* set Tx GMAC FIFO Almost Empty Threshold */
