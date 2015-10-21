From: Punit Vara <punitvara@gmail.com>
Subject: [PATCH 04/15] net: wireless: ipw2x00: use | instead of + for summing bitmasks
Date: Wed, 21 Oct 2015 20:25:26 +0530
Message-ID: <1445439337-19055-5-git-send-email-punitvara@gmail.com>
References: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Cc: stas.yakovlev@gmail.com, chaoming_li@realsil.com.cn,
	Larry.Finger@lwfinger.net, chunkeey@googlemail.com,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	linville@tuxdriver.com, jirislaby@gmail.com, mickflemm@gmail.com,
	mcgrof@do-not-panic.com, k.eugene.e@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to the libipw_rx.c file that fixes following warning
reported by coccicheck:

WARNING: sum of probable bitmasks, consider |

I have replaced + with OR operator | for summing bitmasks

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/ipw2x00/libipw_rx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/libipw_rx.c b/drivers/net/wireless/ipw2x00/libipw_rx.c
index cef7f7d..310b2ff 100644
--- a/drivers/net/wireless/ipw2x00/libipw_rx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_rx.c
@@ -875,7 +875,7 @@ void libipw_rx_any(struct libipw_device *ieee,
 	case IW_MODE_ADHOC:
 		/* our BSS and not from/to DS */
 		if (ether_addr_equal(hdr->addr3, ieee->bssid))
-		if ((fc & (IEEE80211_FCTL_TODS+IEEE80211_FCTL_FROMDS)) == 0) {
+		if ((fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) == 0) {
 			/* promisc: get all */
 			if (ieee->dev->flags & IFF_PROMISC)
 				is_packet_for_us = 1;
@@ -890,7 +890,7 @@ void libipw_rx_any(struct libipw_device *ieee,
 	case IW_MODE_INFRA:
 		/* our BSS (== from our AP) and from DS */
 		if (ether_addr_equal(hdr->addr2, ieee->bssid))
-		if ((fc & (IEEE80211_FCTL_TODS+IEEE80211_FCTL_FROMDS)) == IEEE80211_FCTL_FROMDS) {
+		if ((fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) == IEEE80211_FCTL_FROMDS) {
 			/* promisc: get all */
 			if (ieee->dev->flags & IFF_PROMISC)
 				is_packet_for_us = 1;
-- 
2.5.3
