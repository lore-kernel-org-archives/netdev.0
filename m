From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 8/8] phylib: make phy_scan_fixups() static
Date: Sun, 5 Jan 2014 03:28:27 +0300
Message-ID: <201401050328.28217.sergei.shtylyov@cogentembedded.com>
References: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:64880 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953AbaADX23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 18:28:29 -0500
Received: by mail-lb0-f172.google.com with SMTP id x18so9154826lbi.31
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 15:28:27 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-87-5.pppoe.mtu-net.ru. [91.76.87.5])
        by mx.google.com with ESMTPSA id bl6sm39522433lbb.5.2014.01.04.15.28.26
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 15:28:27 -0800 (PST)
In-Reply-To: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_scan_fixups()  isn't and shouldn't be called by the drivers directly, so
unexport it. And since Florian Fainelli's recent patches, the function is only
called locally, so we can make it static as well.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 2:
- resolved reject, refreshed the patch;
- added signoff.

 drivers/net/phy/phy_device.c |    3 +--
 include/linux/phy.h          |    1 -
 2 files changed, 1 insertion(+), 3 deletions(-)

Index: net-next/drivers/net/phy/phy_device.c
===================================================================
--- net-next.orig/drivers/net/phy/phy_device.c
+++ net-next/drivers/net/phy/phy_device.c
@@ -122,7 +122,7 @@ static int phy_needs_fixup(struct phy_de
 }
 
 /* Runs any matching fixups for this phydev */
-int phy_scan_fixups(struct phy_device *phydev)
+static int phy_scan_fixups(struct phy_device *phydev)
 {
 	struct phy_fixup *fixup;
 
@@ -141,7 +141,6 @@ int phy_scan_fixups(struct phy_device *p
 
 	return 0;
 }
-EXPORT_SYMBOL(phy_scan_fixups);
 
 struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 				     bool is_c45,
Index: net-next/include/linux/phy.h
===================================================================
--- net-next.orig/include/linux/phy.h
+++ net-next/include/linux/phy.h
@@ -596,7 +596,6 @@ int phy_register_fixup_for_id(const char
 			      int (*run)(struct phy_device *));
 int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
 			       int (*run)(struct phy_device *));
-int phy_scan_fixups(struct phy_device *phydev);
 
 int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable);
 int phy_get_eee_err(struct phy_device *phydev);
