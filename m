From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] WAN: use designated initializers
Date: Fri, 16 Dec 2016 16:59:18 -0800
Message-ID: <20161217005918.GA140243@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35812 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759250AbcLQA7U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 19:59:20 -0500
Received: by mail-pg0-f50.google.com with SMTP id p66so37685524pga.2
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 16:59:20 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prepare to mark sensitive kernel structures for randomization by making
sure they're using designated initializers. These were identified during
allyesconfig builds of x86, arm, and arm64, with most initializer fixes
extracted from grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wan/lmc/lmc_media.c | 97 +++++++++++++++++++++--------------------
 1 file changed, 49 insertions(+), 48 deletions(-)

diff --git a/drivers/net/wan/lmc/lmc_media.c b/drivers/net/wan/lmc/lmc_media.c
index 5920c996fcdf..ff2e4a5654c7 100644
--- a/drivers/net/wan/lmc/lmc_media.c
+++ b/drivers/net/wan/lmc/lmc_media.c
@@ -95,62 +95,63 @@ static inline void write_av9110_bit (lmc_softc_t *, int);
 static void write_av9110(lmc_softc_t *, u32, u32, u32, u32, u32);
 
 lmc_media_t lmc_ds3_media = {
-  lmc_ds3_init,			/* special media init stuff */
-  lmc_ds3_default,		/* reset to default state */
-  lmc_ds3_set_status,		/* reset status to state provided */
-  lmc_dummy_set_1,		/* set clock source */
-  lmc_dummy_set2_1,		/* set line speed */
-  lmc_ds3_set_100ft,		/* set cable length */
-  lmc_ds3_set_scram,		/* set scrambler */
-  lmc_ds3_get_link_status,	/* get link status */
-  lmc_dummy_set_1,		/* set link status */
-  lmc_ds3_set_crc_length,	/* set CRC length */
-  lmc_dummy_set_1,		/* set T1 or E1 circuit type */
-  lmc_ds3_watchdog
+  .init = lmc_ds3_init,				/* special media init stuff */
+  .defaults = lmc_ds3_default,			/* reset to default state */
+  .set_status = lmc_ds3_set_status,		/* reset status to state provided */
+  .set_clock_source = lmc_dummy_set_1,		/* set clock source */
+  .set_speed = lmc_dummy_set2_1,		/* set line speed */
+  .set_cable_length = lmc_ds3_set_100ft,	/* set cable length */
+  .set_scrambler = lmc_ds3_set_scram,		/* set scrambler */
+  .get_link_status = lmc_ds3_get_link_status,	/* get link status */
+  .set_link_status = lmc_dummy_set_1,		/* set link status */
+  .set_crc_length = lmc_ds3_set_crc_length,	/* set CRC length */
+  .set_circuit_type = lmc_dummy_set_1,		/* set T1 or E1 circuit type */
+  .watchdog = lmc_ds3_watchdog
 };
 
 lmc_media_t lmc_hssi_media = {
-  lmc_hssi_init,		/* special media init stuff */
-  lmc_hssi_default,		/* reset to default state */
-  lmc_hssi_set_status,		/* reset status to state provided */
-  lmc_hssi_set_clock,		/* set clock source */
-  lmc_dummy_set2_1,		/* set line speed */
-  lmc_dummy_set_1,		/* set cable length */
-  lmc_dummy_set_1,		/* set scrambler */
-  lmc_hssi_get_link_status,	/* get link status */
-  lmc_hssi_set_link_status,	/* set link status */
-  lmc_hssi_set_crc_length,	/* set CRC length */
-  lmc_dummy_set_1,		/* set T1 or E1 circuit type */
-  lmc_hssi_watchdog
+  .init = lmc_hssi_init,			/* special media init stuff */
+  .defaults = lmc_hssi_default,			/* reset to default state */
+  .set_status = lmc_hssi_set_status,		/* reset status to state provided */
+  .set_clock_source = lmc_hssi_set_clock,	/* set clock source */
+  .set_speed = lmc_dummy_set2_1,		/* set line speed */
+  .set_cable_length = lmc_dummy_set_1,		/* set cable length */
+  .set_scrambler = lmc_dummy_set_1,		/* set scrambler */
+  .get_link_status = lmc_hssi_get_link_status,	/* get link status */
+  .set_link_status = lmc_hssi_set_link_status,	/* set link status */
+  .set_crc_length = lmc_hssi_set_crc_length,	/* set CRC length */
+  .set_circuit_type = lmc_dummy_set_1,		/* set T1 or E1 circuit type */
+  .watchdog = lmc_hssi_watchdog
 };
 
-lmc_media_t lmc_ssi_media = { lmc_ssi_init,	/* special media init stuff */
-  lmc_ssi_default,		/* reset to default state */
-  lmc_ssi_set_status,		/* reset status to state provided */
-  lmc_ssi_set_clock,		/* set clock source */
-  lmc_ssi_set_speed,		/* set line speed */
-  lmc_dummy_set_1,		/* set cable length */
-  lmc_dummy_set_1,		/* set scrambler */
-  lmc_ssi_get_link_status,	/* get link status */
-  lmc_ssi_set_link_status,	/* set link status */
-  lmc_ssi_set_crc_length,	/* set CRC length */
-  lmc_dummy_set_1,		/* set T1 or E1 circuit type */
-  lmc_ssi_watchdog
+lmc_media_t lmc_ssi_media = {
+  .init = lmc_ssi_init,				/* special media init stuff */
+  .defaults = lmc_ssi_default,			/* reset to default state */
+  .set_status = lmc_ssi_set_status,		/* reset status to state provided */
+  .set_clock_source = lmc_ssi_set_clock,	/* set clock source */
+  .set_speed = lmc_ssi_set_speed,		/* set line speed */
+  .set_cable_length = lmc_dummy_set_1,		/* set cable length */
+  .set_scrambler = lmc_dummy_set_1,		/* set scrambler */
+  .get_link_status = lmc_ssi_get_link_status,	/* get link status */
+  .set_link_status = lmc_ssi_set_link_status,	/* set link status */
+  .set_crc_length = lmc_ssi_set_crc_length,	/* set CRC length */
+  .set_circuit_type = lmc_dummy_set_1,		/* set T1 or E1 circuit type */
+  .watchdog = lmc_ssi_watchdog
 };
 
 lmc_media_t lmc_t1_media = {
-  lmc_t1_init,			/* special media init stuff */
-  lmc_t1_default,		/* reset to default state */
-  lmc_t1_set_status,		/* reset status to state provided */
-  lmc_t1_set_clock,		/* set clock source */
-  lmc_dummy_set2_1,		/* set line speed */
-  lmc_dummy_set_1,		/* set cable length */
-  lmc_dummy_set_1,		/* set scrambler */
-  lmc_t1_get_link_status,	/* get link status */
-  lmc_dummy_set_1,		/* set link status */
-  lmc_t1_set_crc_length,	/* set CRC length */
-  lmc_t1_set_circuit_type,	/* set T1 or E1 circuit type */
-  lmc_t1_watchdog
+  .init = lmc_t1_init,				/* special media init stuff */
+  .defaults = lmc_t1_default,			/* reset to default state */
+  .set_status = lmc_t1_set_status,		/* reset status to state provided */
+  .set_clock_source = lmc_t1_set_clock,		/* set clock source */
+  .set_speed = lmc_dummy_set2_1,		/* set line speed */
+  .set_cable_length = lmc_dummy_set_1,		/* set cable length */
+  .set_scrambler = lmc_dummy_set_1,		/* set scrambler */
+  .get_link_status = lmc_t1_get_link_status,	/* get link status */
+  .set_link_status = lmc_dummy_set_1,		/* set link status */
+  .set_crc_length = lmc_t1_set_crc_length,	/* set CRC length */
+  .set_circuit_type = lmc_t1_set_circuit_type,	/* set T1 or E1 circuit type */
+  .watchdog = lmc_t1_watchdog
 };
 
 static void
-- 
2.7.4


-- 
Kees Cook
Nexus Security
