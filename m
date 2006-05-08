From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 3/9] sky2: tx ring index mask fix
Date: Mon, 08 May 2006 15:11:28 -0700
Message-ID: <20060508221228.570587000@localhost.localdomain>
References: <20060508221125.177816000@localhost.localdomain>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:11709 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751286AbWEHWXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 18:23:52 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k48MNmtH003749
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:49 -0700
Received: from shell0.pdx.osdl.net (localhost [127.0.0.1])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k48MNmdw023550
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:48 -0700
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=sky2-tx-index.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mask for transmit ring status was picking up bits from the
unused sync ring.  They were always zero, so far...
Also, make sure to remind self not to make tx ring too big.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c
+++ sky2/drivers/net/sky2.c
@@ -1927,7 +1927,8 @@ static int sky2_status_intr(struct sky2_
 
 		case OP_TXINDEXLE:
 			/* TX index reports status for both ports */
-			sky2_tx_done(hw->dev[0], status & 0xffff);
+			BUILD_BUG_ON(TX_RING_SIZE > 0x1000);
+			sky2_tx_done(hw->dev[0], status & 0xfff);
 			if (hw->dev[1])
 				sky2_tx_done(hw->dev[1],
 				     ((status >> 24) & 0xff)

--

