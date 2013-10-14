From: "Sebastian =?ISO-8859-1?Q?P=F6hn?=" <sebastian.poehn@gmail.com>
Subject: [PATCHv2] staging: octeon-ethernet: trivial: Avoid OOPS if phydev
 is not set
Date: Mon, 14 Oct 2013 19:58:55 +0200
Message-ID: <1381773535.2049.4.camel@alpha.Speedport_W723_V_Typ_A_1_00_098>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	dan.carpenter@oracle.com
To: "driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:64049 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756723Ab3JNR7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 13:59:02 -0400
Received: by mail-ee0-f41.google.com with SMTP id d17so3584420eek.14
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 10:59:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry. Haven't signed off for a while now :(

I bet that this is really an issue of incorrect OF information. If I find out more I'll let you know.

@dan: The code works for some interfaces - so phydev is set correctly in some cases.

Signed-off-by: Sebastian Poehn <sebastian.poehn@googlemail.com>
---
diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/octeon/ethernet-mdio.c
index 83b1030..bc8c503 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -121,6 +121,9 @@ static void cvm_oct_adjust_link(struct net_device *dev)
 	struct octeon_ethernet *priv = netdev_priv(dev);
 	cvmx_helper_link_info_t link_info;
 
+	if (!priv->phydev)
+		return;
+
 	if (priv->last_link != priv->phydev->link) {
 		priv->last_link = priv->phydev->link;
 		link_info.u64 = 0;
