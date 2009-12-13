From: re.emese@gmail.com
Subject: [PATCH 2/3] Constify struct e1000_phy_operations 2.6.32-git-a252e7 v2
Date: Mon, 14 Dec 2009 00:59:41 +0100
Message-ID: <77b96dd78a79db43a6a3706f0aa064a8820cb0a0.1260707013.git.re.emese@gmail.com>
References: <cover.1260707013.git.re.emese@gmail.com>
Cc: Emese Revfy <re.emese@gmail.com>, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:34814 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754906AbZLMX5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 18:57:55 -0500
In-Reply-To: <cover.1260707013.git.re.emese@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emese Revfy <re.emese@gmail.com>


Signed-off-by: Emese Revfy <re.emese@gmail.com>
---
 drivers/net/e1000e/82571.c    |    6 +++---
 drivers/net/e1000e/e1000.h    |    2 +-
 drivers/net/e1000e/es2lan.c   |    2 +-
 drivers/net/e1000e/hw.h       |    1 +
 drivers/net/e1000e/ich8lan.c  |    2 +-
 drivers/net/igb/e1000_82575.c |    2 +-
 drivers/net/igb/e1000_hw.h    |    1 +
 7 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index f388cba..12ff45a 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1713,7 +1713,7 @@ static const struct e1000_mac_operations e82571_mac_ops = {
 	.setup_led		= e1000e_setup_led_generic,
 };
 
-static struct e1000_phy_operations e82_phy_ops_igp = {
+static const struct e1000_phy_operations e82_phy_ops_igp = {
 	.acquire		= e1000_get_hw_semaphore_82571,
 	.check_polarity		= e1000_check_polarity_igp,
 	.check_reset_block	= e1000e_check_reset_block_generic,
@@ -1731,7 +1731,7 @@ static struct e1000_phy_operations e82_phy_ops_igp = {
 	.cfg_on_link_up      	= NULL,
 };
 
-static struct e1000_phy_operations e82_phy_ops_m88 = {
+static const struct e1000_phy_operations e82_phy_ops_m88 = {
 	.acquire		= e1000_get_hw_semaphore_82571,
 	.check_polarity		= e1000_check_polarity_m88,
 	.check_reset_block	= e1000e_check_reset_block_generic,
@@ -1749,7 +1749,7 @@ static struct e1000_phy_operations e82_phy_ops_m88 = {
 	.cfg_on_link_up      	= NULL,
 };
 
-static struct e1000_phy_operations e82_phy_ops_bm = {
+static const struct e1000_phy_operations e82_phy_ops_bm = {
 	.acquire		= e1000_get_hw_semaphore_82571,
 	.check_polarity		= e1000_check_polarity_m88,
 	.check_reset_block	= e1000e_check_reset_block_generic,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 68e66b2..24b704c 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -380,7 +380,7 @@ struct e1000_info {
 	u32			max_hw_frame_size;
 	s32			(*get_variants)(struct e1000_adapter *);
 	const struct e1000_mac_operations *mac_ops;
-	struct e1000_phy_operations *phy_ops;
+	const struct e1000_phy_operations *phy_ops;
 	struct e1000_nvm_operations *nvm_ops;
 };
 
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index c44d30a..2e8217e 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1390,7 +1390,7 @@ static const struct e1000_mac_operations es2_mac_ops = {
 	.setup_led		= e1000e_setup_led_generic,
 };
 
-static struct e1000_phy_operations es2_phy_ops = {
+static const struct e1000_phy_operations es2_phy_ops = {
 	.acquire		= e1000_acquire_phy_80003es2lan,
 	.check_polarity		= e1000_check_polarity_m88,
 	.check_reset_block	= e1000e_check_reset_block_generic,
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 2238d4d..a51cbeb 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -828,6 +828,7 @@ struct e1000_mac_info {
 };
 
 struct e1000_phy_info {
+	/* cannot be const, see drivers/net/e1000e/82571.c:e1000_init_phy_params_82571 */
 	struct e1000_phy_operations ops;
 
 	enum e1000_phy_type type;
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 614a0d4..eefef85 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -3309,7 +3309,7 @@ static const struct e1000_mac_operations ich8_mac_ops = {
 	/* id_led_init dependent on mac type */
 };
 
-static struct e1000_phy_operations ich8_phy_ops = {
+static const struct e1000_phy_operations ich8_phy_ops = {
 	.acquire		= e1000_acquire_swflag_ich8lan,
 	.check_reset_block	= e1000_check_reset_block_ich8lan,
 	.commit			= NULL,
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 34b847a..050dc32 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1593,7 +1593,7 @@ static const struct e1000_mac_operations e1000_mac_ops_82575 = {
 	.get_speed_and_duplex = igb_get_speed_and_duplex_copper,
 };
 
-static struct e1000_phy_operations e1000_phy_ops_82575 = {
+static const struct e1000_phy_operations e1000_phy_ops_82575 = {
 	.acquire              = igb_acquire_phy_82575,
 	.get_cfg_done         = igb_get_cfg_done_82575,
 	.release              = igb_release_phy_82575,
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 854b252..937540f 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -378,6 +378,7 @@ struct e1000_mac_info {
 };
 
 struct e1000_phy_info {
+	/* cannot be const, see drivers/net/igb/e1000_82575.c:igb_get_invariants_82575 */
 	struct e1000_phy_operations ops;
 
 	enum e1000_phy_type type;
-- 
1.6.5.3

