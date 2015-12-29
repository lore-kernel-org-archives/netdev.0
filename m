From: Insu Yun <wuninsu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] mwifiex: correctly handling kzalloc
Date: Tue, 29 Dec 2015 14:55:25 -0500
Message-ID: <1451418925-11735-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo-/4noJB3qBVQ3uPMLIKxrzw@public.gmane.org, yeongjin.jang-/4noJB3qBVQ3uPMLIKxrzw@public.gmane.org, insu-/4noJB3qBVQ3uPMLIKxrzw@public.gmane.org,
	changwoo-/4noJB3qBVQ3uPMLIKxrzw@public.gmane.org, Insu Yun <wuninsu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Since kzalloc can be failed in memory pressure,
it needs to be handled as above kzalloc.

Signed-off-by: Insu Yun <wuninsu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/mwifiex/sdio.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/mwifiex/sdio.c
index 78a8474..d114934 100644
--- a/drivers/net/wireless/mwifiex/sdio.c
+++ b/drivers/net/wireless/mwifiex/sdio.c
@@ -2053,8 +2053,14 @@ static int mwifiex_init_sdio(struct mwifiex_adapter *adapter)
 	/* Allocate skb pointer buffers */
 	card->mpa_rx.skb_arr = kzalloc((sizeof(void *)) *
 				       card->mp_agg_pkt_limit, GFP_KERNEL);
+	if (!card->mpa_rx.skb_arr)
+		return -ENOMEM;
+
 	card->mpa_rx.len_arr = kzalloc(sizeof(*card->mpa_rx.len_arr) *
 				       card->mp_agg_pkt_limit, GFP_KERNEL);
+	if (!card->mpa_rx.len_arr)
+		return -ENOMEM;
+
 	ret = mwifiex_alloc_sdio_mpa_buffers(adapter,
 					     card->mp_tx_agg_buf_size,
 					     card->mp_rx_agg_buf_size);
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
