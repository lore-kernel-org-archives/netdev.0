From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH v3 3/5] net: dsa: mv88e6xxx: add common remove function
Date: Thu, 29 Oct 2015 15:45:36 +0100
Message-ID: <56323110.8060505@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34379 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbbJ2Opm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 10:45:42 -0400
Received: by wikq8 with SMTP id q8so286716742wik.1
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 07:45:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the previously introduced remove callback, add a
mv88e6xxx common remove function to cleanup all resources.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/mv88e6xxx.c | 8 ++++++++
 drivers/net/dsa/mv88e6xxx.h | 1 +
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b1b14f5..3bd63f1 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2083,6 +2083,14 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	return 0;
 }

+void mv88e6xxx_remove_common(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	cancel_work_sync(&ps->bridge_work);
+	flush_work(&ps->bridge_work);
+}
+
 int mv88e6xxx_setup_global(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 6f9ed5d..60acaaf 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -417,6 +417,7 @@ struct mv88e6xxx_hw_stat {
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
 int mv88e6xxx_setup_ports(struct dsa_switch *ds);
 int mv88e6xxx_setup_common(struct dsa_switch *ds);
+void mv88e6xxx_remove_common(struct dsa_switch *ds);
 int mv88e6xxx_setup_global(struct dsa_switch *ds);
 int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg);
 int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg);
-- 
1.9.1
