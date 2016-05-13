From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] lxt: simplify lxt97[01]_config_intr()
Date: Fri, 13 May 2016 16:08:02 -0700 (PDT)
Message-ID: <3283503.PbKcWWN225@wasted.cogentembedded.com>
References: <15412071.hrgkzMpf1A@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:36814 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbcEMXIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 19:08:04 -0400
Received: by mail-lb0-f173.google.com with SMTP id h1so31193983lbj.3
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 16:08:03 -0700 (PDT)
In-Reply-To: <15412071.hrgkzMpf1A@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both these functions declare the 'err' local variables for no good reason,
get rid of them.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/phy/lxt.c |   16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

Index: net-next/drivers/net/phy/lxt.c
===================================================================
--- net-next.orig/drivers/net/phy/lxt.c
+++ net-next/drivers/net/phy/lxt.c
@@ -80,14 +80,10 @@ static int lxt970_ack_interrupt(struct p
 
 static int lxt970_config_intr(struct phy_device *phydev)
 {
-	int err;
-
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
-		err = phy_write(phydev, MII_LXT970_IER, MII_LXT970_IER_IEN);
+		return phy_write(phydev, MII_LXT970_IER, MII_LXT970_IER_IEN);
 	else
-		err = phy_write(phydev, MII_LXT970_IER, 0);
-
-	return err;
+		return phy_write(phydev, MII_LXT970_IER, 0);
 }
 
 static int lxt970_config_init(struct phy_device *phydev)
@@ -112,14 +108,10 @@ static int lxt971_ack_interrupt(struct p
 
 static int lxt971_config_intr(struct phy_device *phydev)
 {
-	int err;
-
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
-		err = phy_write(phydev, MII_LXT971_IER, MII_LXT971_IER_IEN);
+		return phy_write(phydev, MII_LXT971_IER, MII_LXT971_IER_IEN);
 	else
-		err = phy_write(phydev, MII_LXT971_IER, 0);
-
-	return err;
+		return phy_write(phydev, MII_LXT971_IER, 0);
 }
 
 /*
