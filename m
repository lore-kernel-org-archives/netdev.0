From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 5/9] drivers/net/wireless: Correct code taking the size of
 a pointer
Date: Sun, 13 Dec 2009 12:42:07 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0912131241470.24267__32535.7498172254$1260704566$gmane$org@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.c
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:39108 "HELO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752587AbZLMLmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 06:42:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

sizeof(iv16) and sizeof(iv32) are the sizes of pointers.  Change them to
the size of the copied data.

A simplified version of the semantic patch that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression *x;
expression f;
type T;
@@

*f(...,(T)x,...)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/rt2x00/rt2800lib.c        |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index eb1e1d0..1e74732 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -2140,8 +2140,8 @@ static void rt2800_get_tkip_seq(struct ieee80211_hw *hw, u8 hw_key_idx,
 	rt2800_register_multiread(rt2x00dev, offset,
 				      &iveiv_entry, sizeof(iveiv_entry));
 
-	memcpy(&iveiv_entry.iv[0], iv16, sizeof(iv16));
-	memcpy(&iveiv_entry.iv[4], iv32, sizeof(iv32));
+	memcpy(&iveiv_entry.iv[0], iv16, sizeof(*iv16));
+	memcpy(&iveiv_entry.iv[4], iv32, sizeof(*iv32));
 }
 
 static int rt2800_set_rts_threshold(struct ieee80211_hw *hw, u32 value)
