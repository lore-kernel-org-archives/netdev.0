From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 03/12] phylib: add a driver method for the SIOCSHWTSTAMP
 ioctl.
Date: Tue, 15 Jun 2010 18:08:06 +0200
Message-ID: <77fe18d640e35dcbfad1e117a4321f935500d5ac.1276615626.git.richard.cochran@omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43726 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121Ab0FOQHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 12:07:15 -0400
Received: by mail-fx0-f46.google.com with SMTP id 10so266600fxm.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 09:07:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1276615626.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a phy driver method for configuring hardware time stamping.
Drivers may optionally implement this function.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/phy/phy.c |    5 +++++
 include/linux/phy.h   |    3 +++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index bd88d81..5130db8 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -361,6 +361,11 @@ int phy_mii_ioctl(struct phy_device *phydev,
 		}
 		break;
 
+	case SIOCSHWTSTAMP:
+		if (phydev->drv->hwtstamp)
+			return phydev->drv->hwtstamp(phydev, ifr);
+		/* fall through */
+
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/include/linux/phy.h b/include/linux/phy.h
index d63736a..a5e9df1 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -402,6 +402,9 @@ struct phy_driver {
 	/* Clears up any memory if needed */
 	void (*remove)(struct phy_device *phydev);
 
+	/* Handles SIOCSHWTSTAMP ioctl for hardware time stamping. */
+	int (*hwtstamp)(struct phy_device *phydev, struct ifreq *ifr);
+
 	struct device_driver driver;
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
-- 
1.6.3.3

