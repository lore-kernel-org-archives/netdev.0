From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 3/4] brcmsmac: delete useless variable
Date: Mon, 13 Jan 2014 17:17:26 +0100
Message-ID: <1389629847-5330-4-git-send-email-Julia.Lawall@lip6.fr>
References: <1389629847-5330-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Brett Rudley <brudley@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389629847-5330-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Delete a variable that is at most only assigned to a constant, but never
used otherwise.

A simplified version of the semantic patch that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
type T;
identifier i;
constant c;
@@

-T i;
<... when != i
-i = c;
...>
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
I don't know whether the comment before the removed assignment should also
be adjusted.

 drivers/net/wireless/brcm80211/brcmsmac/main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index 8138f1c..9417cb5 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -7108,7 +7108,6 @@ prep_mac80211_status(struct brcms_c_info *wlc, struct d11rxhdr *rxh,
 		     struct sk_buff *p,
 		     struct ieee80211_rx_status *rx_status)
 {
-	int preamble;
 	int channel;
 	u32 rspec;
 	unsigned char *plcp;
@@ -7191,7 +7190,6 @@ prep_mac80211_status(struct brcms_c_info *wlc, struct d11rxhdr *rxh,
 			rx_status->rate_idx -= BRCMS_LEGACY_5G_RATE_OFFSET;
 
 		/* Determine short preamble and rate_idx */
-		preamble = 0;
 		if (is_cck_rate(rspec)) {
 			if (rxh->PhyRxStatus_0 & PRXS0_SHORTH)
 				rx_status->flag |= RX_FLAG_SHORTPRE;
