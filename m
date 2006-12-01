From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skge: don't clear MC state on link down
Date: Fri, 1 Dec 2006 11:41:08 -0800
Message-ID: <20061201114108.6166cb47@freekitty>
References: <20061130163531.GB8772@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:41433 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1031762AbWLATlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 14:41:13 -0500
To: Andy Gospodarek <andy@greyhouse.net>,
	Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061130163531.GB8772@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I would rather fix Andy's problem by not clearing
multicast information on link down.

Also, add code to restore multicast state after ethtool phy reset.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 drivers/net/skge.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index b294903..010fc65 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2154,8 +2154,6 @@ static void yukon_link_down(struct skge_
 	int port = skge->port;
 	u16 ctrl;
 
-	gm_phy_write(hw, port, PHY_MARV_INT_MASK, 0);
-
 	ctrl = gma_read16(hw, port, GM_GP_CTRL);
 	ctrl &= ~(GM_GPCR_RX_ENA | GM_GPCR_TX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, ctrl);
@@ -2167,7 +2165,6 @@ static void yukon_link_down(struct skge_
 		gm_phy_write(hw, port, PHY_MARV_AUNE_ADV, ctrl);
 	}
 
-	yukon_reset(hw, port);
 	skge_link_down(skge);
 
 	yukon_init(hw, port);
@@ -2268,6 +2265,8 @@ static void skge_phy_reset(struct skge_p
 		yukon_init(hw, port);
 	}
 	mutex_unlock(&hw->phy_mutex);
+
+	dev->set_multicast_list(dev);
 }
 
 /* Basic MII support */
-- 
1.4.1

