From: Emil Goode <emilgoode@gmail.com>
Subject: [PATCH v2] brcmfmac: Fix off by one bug in brcmf_count_20mhz_channels()
Date: Tue, 23 Sep 2014 00:49:55 +0200
Message-ID: <1411426195-13467-1-git-send-email-emilgoode@gmail.com>
Cc: linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, Emil Goode <emilgoode@gmail.com>
To: Arend van Spriel <arend@broadcom.com>,
	Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Daniel Kim <dekim@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the brcmf_count_20mhz_channels function we are looping through a list
of channels received from firmware. Since the index of the first channel
is 0 the condition leads to an off by one bug. This is causing us to hit
the WARN_ON_ONCE(1) calls in the brcmu_d11n_decchspec function, which is
how I discovered the bug.

Introduced by:
commit b48d891676f756d48b4d0ee131e4a7a5d43ca417
("brcmfmac: rework wiphy structure setup")

Acked-by: Arend van Spriel <arend@broadcom.com>
Signed-off-by: Emil Goode <emilgoode@gmail.com>
---
v2: Added Arends "Acked-by" tag.

 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index 12a60ca..0517687 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -4924,7 +4924,7 @@ static void brcmf_count_20mhz_channels(struct brcmf_cfg80211_info *cfg,
 	struct brcmu_chan ch;
 	int i;
 
-	for (i = 0; i <= total; i++) {
+	for (i = 0; i < total; i++) {
 		ch.chspec = (u16)le32_to_cpu(chlist->element[i]);
 		cfg->d11inf.decchspec(&ch);
 
-- 
2.1.0
