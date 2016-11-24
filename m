From: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/5] ath10k: Remove unused wmi_p2p_noa_descriptor 'noa' in
 wmi-tlv
Date: Thu, 24 Nov 2016 00:01:58 -0800
Message-ID: <99d0ff42e57d5f62560e72d926b4d69d5d7c418b.1479974100.git.kirtika@chromium.org>
References: <cover.1479974100.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Raja Mani <rmani-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1479974100.git.kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit ca996ec56608 (ath10k: implement wmi-tlv backend)
introduced ath10k_wmi_tlv_op_gen_vdev_start() where
'struct wmi_p2p_noa_descriptor *noa' is defined and set but not used.
Compiling with W=1 gives the following warning, fix it.
drivers/net/wireless/ath/ath10k/wmi-tlv.c: In function ‘ath10k_wmi_tlv_op_gen_vdev_start’:
drivers/net/wireless/ath/ath10k/wmi-tlv.c:1647:33: warning: variable ‘noa’ set but not used [-Wunused-but-set-variable]

Fixes: ca996ec56608 ("ath10k: implement wmi-tlv backend")
Cc: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Cc: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Signed-off-by: Kirtika Ruchandani <kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/wireless/ath/ath10k/wmi-tlv.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/wmi-tlv.c b/drivers/net/wireless/ath/ath10k/wmi-tlv.c
index e64f593..0e4bd29 100644
--- a/drivers/net/wireless/ath/ath10k/wmi-tlv.c
+++ b/drivers/net/wireless/ath/ath10k/wmi-tlv.c
@@ -1644,7 +1644,6 @@ ath10k_wmi_tlv_op_gen_vdev_start(struct ath10k *ar,
 {
	struct wmi_tlv_vdev_start_cmd *cmd;
	struct wmi_channel *ch;
-	struct wmi_p2p_noa_descriptor *noa;
	struct wmi_tlv *tlv;
	struct sk_buff *skb;
	size_t len;
@@ -1702,7 +1701,6 @@ ath10k_wmi_tlv_op_gen_vdev_start(struct ath10k *ar,
	tlv = ptr;
	tlv->tag = __cpu_to_le16(WMI_TLV_TAG_ARRAY_STRUCT);
	tlv->len = 0;
-	noa = (void *)tlv->value;

	/* Note: This is a nested TLV containing:
	 * [wmi_tlv][wmi_p2p_noa_descriptor][wmi_tlv]..
--
2.8.0.rc3.226.g39d4020
