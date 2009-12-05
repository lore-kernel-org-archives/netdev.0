From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH 07/31] Constify struct e1000_nvm_operations for 2.6.32
 v1
Date: Sat, 05 Dec 2009 01:03:01 +0100
Message-ID: <4B19A335.5040303@gmail.com>
References: <4B198670.2000406@gmail.com> <4B198A7E.4080407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, torvalds@linux-foundation.org,
	linux-kernel@
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:39897 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932642AbZLEABN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 19:01:13 -0500
In-Reply-To: <4B198A7E.4080407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emese Revfy <re.emese@gmail.com>

Constify struct e1000_nvm_operations.
Per Dave Miller's suggestion, resend with proper CC list and patch format.

Signed-off-by: Emese Revfy <re.emese@gmail.com>
---
 drivers/net/e1000e/82571.c    |    2 +-
 drivers/net/e1000e/e1000.h    |    2 +-
 drivers/net/e1000e/es2lan.c   |    2 +-
 drivers/net/e1000e/hw.h       |   16 ++++++++--------
 drivers/net/e1000e/ich8lan.c  |    2 +-
 drivers/net/igb/e1000_82575.c |    2 +-
 drivers/net/igb/e1000_hw.h    |   12 ++++++------
 7 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index d1e0563..2a2355f 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1725,7 +1725,7 @@ static struct e1000_phy_operations e82_phy_ops_bm = {
 	.cfg_on_link_up      	= NULL,
 };
 
-static struct e1000_nvm_operations e82571_nvm_ops = {
+static const struct e1000_nvm_operations e82571_nvm_ops = {
 	.acquire_nvm		= e1000_acquire_nvm_82571,
 	.read_nvm		= e1000e_read_nvm_eerd,
 	.release_nvm		= e1000_release_nvm_82571,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 3e187b0..bcdcfb1 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -377,7 +377,7 @@ struct e1000_info {
 	s32			(*get_variants)(struct e1000_adapter *);
 	struct e1000_mac_operations *mac_ops;
 	struct e1000_phy_operations *phy_ops;
-	struct e1000_nvm_operations *nvm_ops;
+	const struct e1000_nvm_operations *nvm_ops;
 };
 
 /* hardware capability, feature, and workaround flags */
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index ae5d736..a980900 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1400,7 +1400,7 @@ static struct e1000_phy_operations es2_phy_ops = {
 	.cfg_on_link_up      	= e1000_cfg_on_link_up_80003es2lan,
 };
 
-static struct e1000_nvm_operations es2_nvm_ops = {
+static const struct e1000_nvm_operations es2_nvm_ops = {
 	.acquire_nvm		= e1000_acquire_nvm_80003es2lan,
 	.read_nvm		= e1000e_read_nvm_eerd,
 	.release_nvm		= e1000_release_nvm_80003es2lan,
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index aaea41e..f7f181f 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -776,13 +776,13 @@ struct e1000_phy_operations {
 
 /* Function pointers for the NVM. */
 struct e1000_nvm_operations {
-	s32  (*acquire_nvm)(struct e1000_hw *);
-	s32  (*read_nvm)(struct e1000_hw *, u16, u16, u16 *);
-	void (*release_nvm)(struct e1000_hw *);
-	s32  (*update_nvm)(struct e1000_hw *);
-	s32  (*valid_led_default)(struct e1000_hw *, u16 *);
-	s32  (*validate_nvm)(struct e1000_hw *);
-	s32  (*write_nvm)(struct e1000_hw *, u16, u16, u16 *);
+	s32  (* const acquire_nvm)(struct e1000_hw *);
+	s32  (* const read_nvm)(struct e1000_hw *, u16, u16, u16 *);
+	void (* const release_nvm)(struct e1000_hw *);
+	s32  (* const update_nvm)(struct e1000_hw *);
+	s32  (* const valid_led_default)(struct e1000_hw *, u16 *);
+	s32  (* const validate_nvm)(struct e1000_hw *);
+	s32  (* const write_nvm)(struct e1000_hw *, u16, u16, u16 *);
 };
 
 struct e1000_mac_info {
@@ -856,7 +856,7 @@ struct e1000_phy_info {
 };
 
 struct e1000_nvm_info {
-	struct e1000_nvm_operations ops;
+	const struct e1000_nvm_operations ops;
 
 	enum e1000_nvm_type type;
 	enum e1000_nvm_override override;
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index eff3f47..8835afa 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -3485,7 +3485,7 @@ static struct e1000_phy_operations ich8_phy_ops = {
 	.write_phy_reg		= e1000e_write_phy_reg_igp,
 };
 
-static struct e1000_nvm_operations ich8_nvm_ops = {
+static const struct e1000_nvm_operations ich8_nvm_ops = {
 	.acquire_nvm		= e1000_acquire_nvm_ich8lan,
 	.read_nvm	 	= e1000_read_nvm_ich8lan,
 	.release_nvm		= e1000_release_nvm_ich8lan,
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index f8f5772..f62d4e1 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1415,7 +1415,7 @@ static struct e1000_phy_operations e1000_phy_ops_82575 = {
 	.release              = igb_release_phy_82575,
 };
 
-static struct e1000_nvm_operations e1000_nvm_ops_82575 = {
+static const struct e1000_nvm_operations e1000_nvm_ops_82575 = {
 	.acquire              = igb_acquire_nvm_82575,
 	.read                 = igb_read_nvm_eerd,
 	.release              = igb_release_nvm_82575,
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 119869b..c31e6b2 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -302,17 +302,17 @@ struct e1000_phy_operations {
 };
 
 struct e1000_nvm_operations {
-	s32  (*acquire)(struct e1000_hw *);
-	s32  (*read)(struct e1000_hw *, u16, u16, u16 *);
-	void (*release)(struct e1000_hw *);
-	s32  (*write)(struct e1000_hw *, u16, u16, u16 *);
+	s32  (* const acquire)(struct e1000_hw *);
+	s32  (* const read)(struct e1000_hw *, u16, u16, u16 *);
+	void (* const release)(struct e1000_hw *);
+	s32  (* const write)(struct e1000_hw *, u16, u16, u16 *);
 };
 
 struct e1000_info {
 	s32 (*get_invariants)(struct e1000_hw *);
 	struct e1000_mac_operations *mac_ops;
 	struct e1000_phy_operations *phy_ops;
-	struct e1000_nvm_operations *nvm_ops;
+	const struct e1000_nvm_operations *nvm_ops;
 };
 
 extern const struct e1000_info e1000_82575_info;
@@ -397,7 +397,7 @@ struct e1000_phy_info {
 };
 
 struct e1000_nvm_info {
-	struct e1000_nvm_operations ops;
+	const struct e1000_nvm_operations ops;
 
 	enum e1000_nvm_type type;
 	enum e1000_nvm_override override;

