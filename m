From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 6/6] phylib: make phy_scan_fixups() static
Date: Sat, 4 Jan 2014 04:23:43 +0300
Message-ID: <201401040423.43977.sergei.shtylyov@cogentembedded.com>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:47739 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbaADAXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:23:41 -0500
Received: by mail-la0-f44.google.com with SMTP id e16so606059lan.3
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 16:23:40 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-83-104.pppoe.mtu-net.ru. [91.76.83.104])
        by mx.google.com with ESMTPSA id mv9sm37502871lbc.0.2014.01.03.16.23.39
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 16:23:39 -0800 (PST)
In-Reply-To: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_scan_fixups() isn't and shouldn't be called by the drivers directly, so
unexport it. And since Florian Fainelli's recent patches, the function is only
called locally, so we can make it static as well.

---
 drivers/net/phy/phy_device.c |    3 +--
 include/linux/phy.h          |    1 -
 2 files changed, 1 insertion(+), 3 deletions(-)

Index: net-next/drivers/net/phy/phy_device.c
===================================================================
--- net-next.orig/drivers/net/phy/phy_device.c
+++ net-next/drivers/net/phy/phy_device.c
@@ -124,7 +124,7 @@ static int phy_needs_fixup(struct phy_de
 }
 
 /* Runs any matching fixups for this phydev */
-int phy_scan_fixups(struct phy_device *phydev)
+static int phy_scan_fixups(struct phy_device *phydev)
 {
 	struct phy_fixup *fixup;
 
@@ -143,7 +143,6 @@ int phy_scan_fixups(struct phy_device *p
 
 	return 0;
 }
-EXPORT_SYMBOL(phy_scan_fixups);
 
 struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 				     bool is_c45,
Index: net-next/include/linux/phy.h
===================================================================
--- net-next.orig/include/linux/phy.h
+++ net-next/include/linux/phy.h
@@ -597,7 +597,6 @@ int phy_register_fixup_for_id(const char
 		int (*run)(struct phy_device *));
 int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
 		int (*run)(struct phy_device *));
-int phy_scan_fixups(struct phy_device *phydev);
 
 int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable);
 int phy_get_eee_err(struct phy_device *phydev);
