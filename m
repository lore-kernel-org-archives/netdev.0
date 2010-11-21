From: Joe Perches <joe@perches.com>
Subject: [PATCH 51/62] ath5k: Use static const
Date: Sat, 20 Nov 2010 18:38:52 -0800
Message-ID: <b2362f9dc7f404ad453c72b9d850a64fd810bc8a.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1724 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757088Ab0KUCkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 21:40:32 -0500
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  11266	     56	   2464	  13786	   35da	drivers/net/wireless/ath/ath5k/ani.o.old
  11181	     56	   2464	  13701	   3585	drivers/net/wireless/ath/ath5k/ani.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath5k/ani.c |   34 +++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/ani.c b/drivers/net/wireless/ath/ath5k/ani.c
index db98a85..6b75b22 100644
--- a/drivers/net/wireless/ath/ath5k/ani.c
+++ b/drivers/net/wireless/ath/ath5k/ani.c
@@ -63,15 +63,15 @@ ath5k_ani_set_noise_immunity_level(struct ath5k_hw *ah, int level)
 	 * so i stick with the HAL version for now...
 	 */
 #if 0
-	const s8 hi[] = { -18, -18, -16, -14, -12 };
-	const s8 lo[] = { -52, -56, -60, -64, -70 };
-	const s8 sz[] = { -34, -41, -48, -55, -62 };
-	const s8 fr[] = { -70, -72, -75, -78, -80 };
+	static const s8 hi[] = { -18, -18, -16, -14, -12 };
+	static const s8 lo[] = { -52, -56, -60, -64, -70 };
+	static const s8 sz[] = { -34, -41, -48, -55, -62 };
+	static const s8 fr[] = { -70, -72, -75, -78, -80 };
 #else
-	const s8 sz[] = { -55, -62 };
-	const s8 lo[] = { -64, -70 };
-	const s8 hi[] = { -14, -12 };
-	const s8 fr[] = { -78, -80 };
+	static const s8 sz[] = { -55, -62 };
+	static const s8 lo[] = { -64, -70 };
+	static const s8 hi[] = { -14, -12 };
+	static const s8 fr[] = { -78, -80 };
 #endif
 	if (level < 0 || level >= ARRAY_SIZE(sz)) {
 		ATH5K_ERR(ah->ah_sc, "noise immuniy level %d out of range",
@@ -102,7 +102,7 @@ ath5k_ani_set_noise_immunity_level(struct ath5k_hw *ah, int level)
 void
 ath5k_ani_set_spur_immunity_level(struct ath5k_hw *ah, int level)
 {
-	const int val[] = { 2, 4, 6, 8, 10, 12, 14, 16 };
+	static const int val[] = { 2, 4, 6, 8, 10, 12, 14, 16 };
 
 	if (level < 0 || level >= ARRAY_SIZE(val) ||
 	    level > ah->ah_sc->ani_state.max_spur_level) {
@@ -127,7 +127,7 @@ ath5k_ani_set_spur_immunity_level(struct ath5k_hw *ah, int level)
 void
 ath5k_ani_set_firstep_level(struct ath5k_hw *ah, int level)
 {
-	const int val[] = { 0, 4, 8 };
+	static const int val[] = { 0, 4, 8 };
 
 	if (level < 0 || level >= ARRAY_SIZE(val)) {
 		ATH5K_ERR(ah->ah_sc, "firstep level %d out of range", level);
@@ -151,12 +151,12 @@ ath5k_ani_set_firstep_level(struct ath5k_hw *ah, int level)
 void
 ath5k_ani_set_ofdm_weak_signal_detection(struct ath5k_hw *ah, bool on)
 {
-	const int m1l[] = { 127, 50 };
-	const int m2l[] = { 127, 40 };
-	const int m1[] = { 127, 0x4d };
-	const int m2[] = { 127, 0x40 };
-	const int m2cnt[] = { 31, 16 };
-	const int m2lcnt[] = { 63, 48 };
+	static const int m1l[] = { 127, 50 };
+	static const int m2l[] = { 127, 40 };
+	static const int m1[] = { 127, 0x4d };
+	static const int m2[] = { 127, 0x40 };
+	static const int m2cnt[] = { 31, 16 };
+	static const int m2lcnt[] = { 63, 48 };
 
 	AR5K_REG_WRITE_BITS(ah, AR5K_PHY_WEAK_OFDM_LOW_THR,
 				AR5K_PHY_WEAK_OFDM_LOW_THR_M1, m1l[on]);
@@ -192,7 +192,7 @@ ath5k_ani_set_ofdm_weak_signal_detection(struct ath5k_hw *ah, bool on)
 void
 ath5k_ani_set_cck_weak_signal_detection(struct ath5k_hw *ah, bool on)
 {
-	const int val[] = { 8, 6 };
+	static const int val[] = { 8, 6 };
 	AR5K_REG_WRITE_BITS(ah, AR5K_PHY_CCK_CROSSCORR,
 				AR5K_PHY_CCK_CROSSCORR_WEAK_SIG_THR, val[on]);
 	ah->ah_sc->ani_state.cck_weak_sig = on;
-- 
1.7.3.2.245.g03276.dirty

