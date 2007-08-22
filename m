From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] Net: ath5k, no printk after STA->IBSS switch
Date: Wed, 22 Aug 2007 22:53:25 +0200 (CEST)
Message-ID: <2698018635706419125@wsc.cz>
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

ath5k, no printk after STA->IBSS switch

If STA->IBSS switch was done, but beacon_update weas not called so far, do
not emit a warning about non-existent skbuf.

Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

---
commit b01c0e9a02b248c3e2f2923da9728ba2c3961dee
tree c3e10a57aed39698f20c346679854aa3a9a54639
parent 8c5f91fb39c6208b23306687343cc5fbf830fa17
author Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Wed, 22 Aug 2007 22:47:06 +0200
committer Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Wed, 22 Aug 2007 22:47:06 +0200

 drivers/net/wireless/ath5k_base.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath5k_base.c b/drivers/net/wireless/ath5k_base.c
index 847218b..2ce82ed 100644
--- a/drivers/net/wireless/ath5k_base.c
+++ b/drivers/net/wireless/ath5k_base.c
@@ -655,7 +655,9 @@ static void ath_beacon_config(struct ath_softc *sc)
 	DPRINTF(sc, ATH_DEBUG_BEACON, "%s: intval %u hw tsftu %u\n", __func__,
 			intval, tsftu);
 
-	if (sc->opmode == IEEE80211_IF_TYPE_STA) {
+	if (sc->opmode == IEEE80211_IF_TYPE_STA ||
+			(sc->opmode == IEEE80211_IF_TYPE_IBSS &&
+				!sc->bbuf->skb)) {
 		ath5k_hw_set_intr(ah, 0);
 		sc->imask |= AR5K_INT_BMISS;
 		sc->bmisscount = 0;
