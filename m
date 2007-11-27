From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/3] sky2: turn of dynamic Tx watermark workaround (FE+
 only)
Date: Tue, 27 Nov 2007 11:02:07 -0800
Message-ID: <20071127110207.0d65e820@freepuppy.rosehill>
References: <20071127105727.1bcfa56f@freepuppy.rosehill>
	<20071127110036.0268c0a9@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tim Gardner <tim.gardner@canonical.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38159 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757944AbXK0WKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 17:10:31 -0500
In-Reply-To: <20071127110036.0268c0a9@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add workaround for issues FE+ (A0) transmit watermark.
This is copied verbatim from vendor driver sk98lin (10.22.4.3).
Don't have that chip version and no more information seems to be available.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-11-26 14:02:36.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-26 14:28:47.000000000 -0800
@@ -845,6 +845,13 @@ static void sky2_mac_init(struct sky2_hw
 		sky2_set_tx_stfwd(hw, port);
 	}
 
+	if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
+	    hw->chip_rev == CHIP_REV_YU_FE2_A0) {
+		/* disable dynamic watermark */
+		reg = sky2_read16(hw, SK_REG(port, TX_GMF_EA));
+		reg &= ~TX_DYN_WM_ENA;
+		sky2_write16(hw, SK_REG(port, TX_GMF_EA), reg);
+	}
 }
 
 /* Assign Ram Buffer allocation to queue */
