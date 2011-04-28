From: artpol <artpol84@gmail.com>
Subject: [PATCH 2.6.38.4] mii: add support of pause frames in mii_get_an
Date: Thu, 28 Apr 2011 10:49:14 +0700
Message-ID: <1303962554.15395.1.camel@artpol-thinkpad>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support of pause frames advertise in mii_get_an. This provides all drivers 
that use mii_ethtool_gset to represent their own and Link partner flow control
abilities in ethtool.

Signed-off-by: Artem Polyakov <artpol84@gmail.com>

---

--- linux-2.6.38.4/drivers/net/mii.c.orig	2011-04-28 08:46:13.000000000 +0700
+++ linux-2.6.38.4/drivers/net/mii.c	2011-04-25 23:04:20.694981968 +0700
@@ -49,6 +49,10 @@ static u32 mii_get_an(struct mii_if_info
 		result |= ADVERTISED_100baseT_Half;
 	if (advert & ADVERTISE_100FULL)
 		result |= ADVERTISED_100baseT_Full;
+	if (advert & ADVERTISE_PAUSE_CAP)
+		result |= ADVERTISED_Pause;
+	if (advert & ADVERTISE_PAUSE_ASYM)
+		result |= ADVERTISED_Asym_Pause;
 
 	return result;
 }
