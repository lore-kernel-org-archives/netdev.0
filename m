From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] skge: restore device multicast membership after link down/up
Date: Thu, 30 Nov 2006 11:35:32 -0500
Message-ID: <20061130163531.GB8772@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40133 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1759260AbWK3Qfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 11:35:39 -0500
To: netdev@vger.kernel.org, shemminger@osdl.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Yukon hardware will lose multicast membership data and promiscuous mode 
information if a link is disconnected and reconnected without taking the
interface down.  A call to yukon_reset in yukon_link_down will clear the
hardware's multicast list, so it needs to be added back on link_up.

It does not appear that Genesis hardware needs a similar patch is needed
since it does not seem to clear multicast membership when taking the
link down.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 skge.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 3f1b72e..c02e1f1 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -1922,6 +1922,10 @@ static void yukon_link_up(struct skge_po
 	gma_write16(hw, port, GM_GP_CTRL, reg);
 
 	gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_IS_DEF_MSK);
+
+	/* reset multicast list */
+	yukon_set_multicast(skge->netdev);
+
 	skge_link_up(skge);
 }
 
