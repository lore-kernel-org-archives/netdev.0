From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCH 1/8] rfkill: Documentation and style fixes
Date: Tue, 19 Jan 2016 10:42:36 -0500
Message-ID: <1453218163-31998-2-git-send-email-jprvita@endlessm.com>
References: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel@holtmann.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jprvita@endlessm.com,
	linux@endlessm.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34479 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754673AbcASPoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 10:44:05 -0500
In-Reply-To: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ixes some small typos, punctuation, and copy & paste issues. Also
removes an extra blank line.

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 include/linux/rfkill.h | 7 ++++---
 net/rfkill/core.c      | 5 ++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
index d901078..3dcbaf6 100644
--- a/include/linux/rfkill.h
+++ b/include/linux/rfkill.h
@@ -104,16 +104,17 @@ int __must_check rfkill_register(struct rfkill *r=
fkill);
  *
  * Pause polling -- say transmitter is off for other reasons.
  * NOTE: not necessary for suspend/resume -- in that case the
- * core stops polling anyway
+ * core stops polling anyway.
  */
 void rfkill_pause_polling(struct rfkill *rfkill);
=20
 /**
  * rfkill_resume_polling(struct rfkill *rfkill)
  *
- * Pause polling -- say transmitter is off for other reasons.
+ * Resume polling previously paused with rfkill_pause_polling.
  * NOTE: not necessary for suspend/resume -- in that case the
- * core stops polling anyway
+ * core restarts polling anyway, even if was explicitly paused
+ * before suspending.
  */
 void rfkill_resume_polling(struct rfkill *rfkill);
=20
diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index f53bf3b6..4d6d726 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -303,8 +303,8 @@ static void rfkill_set_block(struct rfkill *rfkill,=
 bool blocked)
 	spin_lock_irqsave(&rfkill->lock, flags);
 	if (err) {
 		/*
-		 * Failed -- reset status to _prev, this may be different
-		 * from what set set _PREV to earlier in this function
+		 * Failed -- reset status to _PREV. This may be different
+		 * from what we have set _PREV to earlier in this function
 		 * if rfkill_set_sw_state was invoked.
 		 */
 		if (rfkill->state & RFKILL_BLOCK_SW_PREV)
@@ -477,7 +477,6 @@ bool rfkill_get_global_sw_state(const enum rfkill_t=
ype type)
 }
 #endif
=20
-
 bool rfkill_set_hw_state(struct rfkill *rfkill, bool blocked)
 {
 	bool ret, change;
--=20
2.5.0
