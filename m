From: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] cfg80211: use list_move_tail instead of list_del/list_add_tail
Date: Wed, 5 Sep 2012 14:34:12 +0800
Message-ID: <CAPgLHd-7DpM_OQ7RTVip6d-zb8DZS9SiscrMugm2-D992ajjsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>

Using list_move_tail() instead of list_del() + list_add_tail().

Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
---
 net/wireless/reg.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 2ded3c7..1ad04e5 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -1949,8 +1949,7 @@ static void restore_regulatory_settings(bool reset_user)
 			if (reg_request->initiator !=
 			    NL80211_REGDOM_SET_BY_USER)
 				continue;
-			list_del(&reg_request->list);
-			list_add_tail(&reg_request->list, &tmp_reg_req_list);
+			list_move_tail(&reg_request->list, &tmp_reg_req_list);
 		}
 	}
 	spin_unlock(&reg_requests_lock);
@@ -2009,8 +2008,7 @@ static void restore_regulatory_settings(bool reset_user)
 			      "into the queue\n",
 			      reg_request->alpha2[0],
 			      reg_request->alpha2[1]);
-		list_del(&reg_request->list);
-		list_add_tail(&reg_request->list, &reg_requests_list);
+		list_move_tail(&reg_request->list, &reg_requests_list);
 	}
 	spin_unlock(&reg_requests_lock);
 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
