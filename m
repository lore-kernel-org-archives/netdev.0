From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: dsa: update DSA drivers to use ds_to_priv
Date: Mon, 28 Apr 2014 11:14:28 -0700
Message-ID: <1398708868-15084-3-git-send-email-f.fainelli@gmail.com>
References: <1398708868-15084-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:44278 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbaD1TJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:09:23 -0400
Received: by mail-pd0-f178.google.com with SMTP id fp1so3919324pdb.9
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 12:09:22 -0700 (PDT)
In-Reply-To: <1398708868-15084-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the helper function to retrieve the driver private context instead of
using (void *)(ds + 1).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/mv88e6123_61_65.c |  2 +-
 drivers/net/dsa/mv88e6131.c       |  4 ++--
 drivers/net/dsa/mv88e6xxx.c       | 12 ++++++------
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 41ee5b6ae917..69c42513dd72 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -289,7 +289,7 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 
 static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int i;
 	int ret;
 
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index dadfafba64e9..953bc6a49e59 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -155,7 +155,7 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 
 static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 {
-	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int addr = REG_PORT(p);
 	u16 val;
 
@@ -274,7 +274,7 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 
 static int mv88e6131_setup(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int i;
 	int ret;
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 17314ed9456d..9ce2146346b6 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -74,7 +74,7 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 
 int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
 {
-	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
@@ -118,7 +118,7 @@ int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 
 int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 {
-	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
@@ -256,7 +256,7 @@ static void mv88e6xxx_ppu_reenable_timer(unsigned long _ps)
 
 static int mv88e6xxx_ppu_access_get(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->ppu_mutex);
@@ -283,7 +283,7 @@ static int mv88e6xxx_ppu_access_get(struct dsa_switch *ds)
 
 static void mv88e6xxx_ppu_access_put(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
 	/* Schedule a timer to re-enable the PHY polling unit. */
 	mod_timer(&ps->ppu_timer, jiffies + msecs_to_jiffies(10));
@@ -292,7 +292,7 @@ static void mv88e6xxx_ppu_access_put(struct dsa_switch *ds)
 
 void mv88e6xxx_ppu_state_init(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
 	mutex_init(&ps->ppu_mutex);
 	INIT_WORK(&ps->ppu_work, mv88e6xxx_ppu_reenable_work);
@@ -463,7 +463,7 @@ void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 				 int nr_stats, struct mv88e6xxx_hw_stat *stats,
 				 int port, uint64_t *data)
 {
-	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 	int i;
 
-- 
1.9.1
