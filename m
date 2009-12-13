From: re.emese@gmail.com
Subject: [PATCH 3/3] Constify struct e1000_nvm_operations 2.6.32-git-a252e7 v2
Date: Mon, 14 Dec 2009 00:59:42 +0100
Message-ID: <a05ba74a237aeb4b1c744e665190ebdc495e1ed6.1260707013.git.re.emese@gmail.com>
References: <cover.1260707013.git.re.emese@gmail.com>
Cc: Emese Revfy <re.emese@gmail.com>, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:34221 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754938AbZLMX5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 18:57:53 -0500
In-Reply-To: <cover.1260707013.git.re.emese@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emese Revfy <re.emese@gmail.com>


Signed-off-by: Emese Revfy <re.emese@gmail.com>
---
 drivers/net/e1000e/82571.c    |    2 +-
 drivers/net/e1000e/e1000.h    |    2 +-
 drivers/net/e1000e/es2lan.c   |    2 +-
 drivers/net/e1000e/hw.h       |   16 ++++++++--------
 drivers/net/e1000e/ich8lan.c  |    2 +-
 drivers/net/igb/e1000_82575.c |    2 +-
 drivers/net/igb/e1000_hw.h    |    3 ++-
 7 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 12ff45a..738f51d 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1767,7 +1767,7 @@ static const struct e1000_phy_operations e82_phy_ops_bm = {
 	.cfg_on_link_up      	= NULL,
 };
 
-static struct e1000_nvm_operations e82571_nvm_ops = {
+static const struct e1000_nvm_operations e82571_nvm_ops = {
 	.acquire		= e1000_acquire_nvm_82571,
 	.read			= e1000e_read_nvm_eerd,
 	.release		= e1000_release_nvm_82571,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 24b704c..2b42fba 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -381,7 +381,7 @@ struct e1000_info {
 	s32			(*get_variants)(struct e1000_adapter *);
 	const struct e1000_mac_operations *mac_ops;
 	const struct e1000_phy_operations *phy_ops;
-	struct e1000_nvm_operations *nvm_ops;
+	const struct e1000_nvm_operations *nvm_ops;
 };
 
 /* hardware capability, feature, and workaround flags */
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 2e8217e..9ce2d30 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1408,7 +1408,7 @@ static const struct e1000_phy_operations es2_phy_ops = {
 	.cfg_on_link_up      	= e1000_cfg_on_link_up_80003es2lan,
 };
 
-static struct e1000_nvm_operations es2_nvm_ops = {
+static const struct e1000_nvm_operations es2_nvm_ops = {
 	.acquire		= e1000_acquire_nvm_80003es2lan,
 	.read			= e1000e_read_nvm_eerd,
 	.release		= e1000_release_nvm_80003es2lan,
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index a51cbeb..d40e9af 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -781,13 +781,13 @@ struct e1000_phy_operations {
 
 /* Function pointers for the NVM. */
 struct e1000_nvm_operations {
-	s32  (*acquire)(struct e1000_hw *);
-	s32  (*read)(struct e1000_hw *, u16, u16, u16 *);
-	void (*release)(struct e1000_hw *);
-	s32  (*update)(struct e1000_hw *);
-	s32  (*valid_led_default)(struct e1000_hw *, u16 *);
-	s32  (*validate)(struct e1000_hw *);
-	s32  (*write)(struct e1000_hw *, u16, u16, u16 *);
+	s32  (* const acquire)(struct e1000_hw *);
+	s32  (* const read)(struct e1000_hw *, u16, u16, u16 *);
+	void (* const release)(struct e1000_hw *);
+	s32  (* const update)(struct e1000_hw *);
+	s32  (* const valid_led_default)(struct e1000_hw *, u16 *);
+	s32  (* const validate)(struct e1000_hw *);
+	s32  (* const write)(struct e1000_hw *, u16, u16, u16 *);
 };
 
 struct e1000_mac_info {
@@ -863,7 +863,7 @@ struct e1000_phy_info {
 };
 
 struct e1000_nvm_info {
-	struct e1000_nvm_operations ops;
+	const struct e1000_nvm_operations ops;
 
 	enum e1000_nvm_type type;
 	enum e1000_nvm_override override;
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index eefef85..e3efb4a 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -3323,7 +3323,7 @@ static const struct e1000_phy_operations ich8_phy_ops = {
 	.write_reg		= e1000e_write_phy_reg_igp,
 };
 
-static struct e1000_nvm_operations ich8_nvm_ops = {
+static const struct e1000_nvm_operations ich8_nvm_ops = {
 	.acquire		= e1000_acquire_nvm_ich8lan,
 	.read		 	= e1000_read_nvm_ich8lan,
 	.release		= e1000_release_nvm_ich8lan,
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 050dc32..0c52265 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1599,7 +1599,7 @@ static const struct e1000_phy_operations e1000_phy_ops_82575 = {
 	.release              = igb_release_phy_82575,
 };
 
-static struct e1000_nvm_operations e1000_nvm_ops_82575 = {
+static const struct e1000_nvm_operations e1000_nvm_ops_82575 = {
 	.acquire              = igb_acquire_nvm_82575,
 	.read                 = igb_read_nvm_eerd,
 	.release              = igb_release_nvm_82575,
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 937540f..678f006 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -326,7 +326,7 @@ struct e1000_info {
 	s32 (*get_invariants)(struct e1000_hw *);
 	const struct e1000_mac_operations *mac_ops;
 	struct e1000_phy_operations *phy_ops;
-	struct e1000_nvm_operations *nvm_ops;
+	const struct e1000_nvm_operations *nvm_ops;
 };
 
 extern const struct e1000_info e1000_82575_info;
@@ -414,6 +414,7 @@ struct e1000_phy_info {
 };
 
 struct e1000_nvm_info {
+	/* cannot be const, see drivers/net/igb/igb_main.c:igb_probe */
 	struct e1000_nvm_operations ops;
 
 	enum e1000_nvm_type type;
-- 
1.6.5.3

