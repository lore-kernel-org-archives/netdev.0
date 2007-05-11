From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: Re: [PATCH] phylib: phy_ethtool_{sset,gset} -- check phydev for NULL
Date: Fri, 11 May 2007 14:58:41 +0400
Message-ID: <8496f91a0705110358v2e6d9b7el19856eadd55ac596@mail.gmail.com>
References: <8496f91a0705101029g794ee4a7t1c6a34ad13444c49@mail.gmail.com>
	 <20070510105613.f564e083.randy.dunlap@oracle.com>
	 <46436215.7030503@garzik.org>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Randy Dunlap" <randy.dunlap@oracle.com>, netdev@vger.kernel.org
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.181]:39293 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755738AbXEKK6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 06:58:43 -0400
Received: by ik-out-1112.google.com with SMTP id b35so576092ika
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 03:58:42 -0700 (PDT)
In-Reply-To: <46436215.7030503@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
---

diff -purN linux-2.6.21-clean/drivers/net/phy/phy.c
linux-2.6.21/drivers/net/phy/phy.c
--- linux-2.6.21-clean/drivers/net/phy/phy.c	2007-04-26 07:08:32.000000000 +0400
+++ linux-2.6.21/drivers/net/phy/phy.c	2007-05-04 08:22:01.000000000 +0400
@@ -245,6 +245,9 @@ EXPORT_SYMBOL(phy_sanitize_settings);
  */
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 {
+	if (unlikely(!phydev))
+		return -EINVAL;
+
 	if (cmd->phy_address != phydev->addr)
 		return -EINVAL;

@@ -289,6 +292,9 @@ EXPORT_SYMBOL(phy_ethtool_sset);

 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 {
+	if (unlikely(!phydev))
+		return -EINVAL;
+
 	cmd->supported = phydev->supported;

 	cmd->advertising = phydev->advertising;
