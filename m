From: Shawn Lin <shawn.lin-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH] mwifiex: simplify the code around ra_list
Date: Fri, 26 May 2017 09:41:49 +0800
Message-ID: <1495762909-46795-1-git-send-email-shawn.lin@rock-chips.com>
Cc: Xinming Hu <huxm-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shawn Lin <shawn.lin-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: Amitkumar Karwar <amitkarwar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We don't need to check if the list is empty separately
as we could use list_first_entry_or_null to cover it.

Signed-off-by: Shawn Lin <shawn.lin-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---

 drivers/net/wireless/marvell/mwifiex/tdls.c | 7 ++-----
 drivers/net/wireless/marvell/mwifiex/wmm.c  | 8 ++------
 2 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/tdls.c b/drivers/net/wireless/marvell/mwifiex/tdls.c
index 7d0d3ff..d76ce87 100644
--- a/drivers/net/wireless/marvell/mwifiex/tdls.c
+++ b/drivers/net/wireless/marvell/mwifiex/tdls.c
@@ -55,11 +55,8 @@ static void mwifiex_restore_tdls_packets(struct mwifiex_private *priv,
 			tx_info->flags |= MWIFIEX_BUF_FLAG_TDLS_PKT;
 		} else {
 			tid_list = &priv->wmm.tid_tbl_ptr[tid_down].ra_list;
-			if (!list_empty(tid_list))
-				ra_list = list_first_entry(tid_list,
-					      struct mwifiex_ra_list_tbl, list);
-			else
-				ra_list = NULL;
+			ra_list = list_first_entry_or_null(tid_list,
+					struct mwifiex_ra_list_tbl, list);
 			tx_info->flags &= ~MWIFIEX_BUF_FLAG_TDLS_PKT;
 		}
 
diff --git a/drivers/net/wireless/marvell/mwifiex/wmm.c b/drivers/net/wireless/marvell/mwifiex/wmm.c
index e4ff3b9..744b014 100644
--- a/drivers/net/wireless/marvell/mwifiex/wmm.c
+++ b/drivers/net/wireless/marvell/mwifiex/wmm.c
@@ -868,12 +868,8 @@ struct mwifiex_ra_list_tbl *
 			return;
 		default:
 			list_head = priv->wmm.tid_tbl_ptr[tid_down].ra_list;
-			if (!list_empty(&list_head))
-				ra_list = list_first_entry(
-					&list_head, struct mwifiex_ra_list_tbl,
-					list);
-			else
-				ra_list = NULL;
+			ra_list = list_first_entry_or_null(&list_head,
+					struct mwifiex_ra_list_tbl, list);
 			break;
 		}
 	} else {
-- 
1.9.1
