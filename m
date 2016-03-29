From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/16] wcn36xx: Copy all members in config_sta v1 conversion
Date: Mon, 28 Mar 2016 23:06:27 -0700
Message-ID: <1459231593-360-11-git-send-email-bjorn.andersson@linaro.org>
References: <1459231593-360-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1459231593-360-1-git-send-email-bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

When converting to version 1 of the config_sta struct not all
members where copied. This fixes the problem of multicast frames
not being delivered on an encrypted network.

Signed-off-by: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 2b416ee9f105..ce764cce1a3e 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -949,17 +949,32 @@ static void wcn36xx_smd_convert_sta_to_v1(struct wcn36xx *wcn,
 	memcpy(&v1->mac, orig->mac, ETH_ALEN);
 	v1->aid = orig->aid;
 	v1->type = orig->type;
+	v1->short_preamble_supported = orig->short_preamble_supported;
 	v1->listen_interval = orig->listen_interval;
+	v1->wmm_enabled = orig->wmm_enabled;
 	v1->ht_capable = orig->ht_capable;
-
+	v1->tx_channel_width_set = orig->tx_channel_width_set;
+	v1->rifs_mode = orig->rifs_mode;
+	v1->lsig_txop_protection = orig->lsig_txop_protection;
 	v1->max_ampdu_size = orig->max_ampdu_size;
 	v1->max_ampdu_density = orig->max_ampdu_density;
 	v1->sgi_40mhz = orig->sgi_40mhz;
 	v1->sgi_20Mhz = orig->sgi_20Mhz;
