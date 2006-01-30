From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] RealTek RTL-8169 Full Duplex Patch
Date: Mon, 30 Jan 2006 10:10:29 -0600
Message-ID: <20060130161029.GA11938@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932309AbWA3PMr@vger.kernel.org>
To: netdev@vger.kernel.org, romieu@fr.zoreil.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Allow the r8129 driver to set devices to be full-duplex only when
auto-negotiate is disabled.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 r8169.c |    3 +++
 1 files changed, 3 insertions(+)

--- 2.6/drivers/net/r8169.c.orig	2006-01-23 12:55:19.224875000 -0600
+++ 2.6/drivers/net/r8169.c	2006-01-23 13:29:54.967655000 -0600
@@ -677,6 +677,9 @@
 
 		if (duplex == DUPLEX_HALF)
 			auto_nego &= ~(PHY_Cap_10_Full | PHY_Cap_100_Full);
+
+		if (duplex == DUPLEX_FULL)
+			auto_nego &= ~(PHY_Cap_10_Half | PHY_Cap_100_Half);
 	}
 
 	tp->phy_auto_nego_reg = auto_nego;
