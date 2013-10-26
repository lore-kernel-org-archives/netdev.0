From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH 01/16] mac80211: fix TX device statistics for monitor interfaces
Date: Sat, 26 Oct 2013 22:34:00 +0200
Message-ID: <1382819655-30430-2-git-send-email-pali.rohar@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com, pali.rohar@gmail.com,
	David Gnedt <david.gnedt@davizone.at>
To: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Gnedt <david.gnedt@davizone.at>

Count TX packets and bytes also for monitor interfaces.

Signed-of-by: David Gnedt <david.gnedt@davizone.at>
---
 net/mac80211/tx.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 3456c04..674db8e 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1593,6 +1593,9 @@ netdev_tx_t ieee80211_monitor_start_xmit(struct sk_buff *skb,
 	if (unlikely(skb->len < len_rthdr))
 		goto fail; /* skb too short for claimed rt header extent */
 
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
 	/*
 	 * fix up the pointers accounting for the radiotap
 	 * header still being in there.  We are being given
-- 
1.7.10.4
