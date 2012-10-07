From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ptp: use list_move instead of list_del/list_add
Date: Sun, 7 Oct 2012 21:41:50 +0800
Message-ID: <CAPgLHd87UYDK7f=scccBq7AAO67=9pcg5CdKBG0+8i0kPFtXAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: linux-net-drivers@solarflare.com, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:43723 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047Ab2JGNlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 09:41:51 -0400
Received: by mail-qc0-f180.google.com with SMTP id v28so2205151qcm.11
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2012 06:41:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using list_move() instead of list_del() + list_add().

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/sfc/ptp.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 5b3dd02..0767043f 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -640,8 +640,7 @@ static void efx_ptp_drop_time_expired_events(struct efx_nic *efx)
 			evt = list_entry(cursor, struct efx_ptp_event_rx,
 					 link);
 			if (time_after(jiffies, evt->expiry)) {
-				list_del(&evt->link);
-				list_add(&evt->link, &ptp->evt_free_list);
+				list_move(&evt->link, &ptp->evt_free_list);
 				netif_warn(efx, hw, efx->net_dev,
 					   "PTP rx event dropped\n");
 			}
@@ -684,8 +683,7 @@ static enum ptp_packet_state efx_ptp_match_rx(struct efx_nic *efx,
 
 			match->state = PTP_PACKET_STATE_MATCHED;
 			rc = PTP_PACKET_STATE_MATCHED;
-			list_del(&evt->link);
-			list_add(&evt->link, &ptp->evt_free_list);
+			list_move(&evt->link, &ptp->evt_free_list);
 			break;
 		}
 	}
@@ -820,8 +818,7 @@ static int efx_ptp_stop(struct efx_nic *efx)
 	/* Drop any pending receive events */
 	spin_lock_bh(&efx->ptp_data->evt_lock);
 	list_for_each_safe(cursor, next, &efx->ptp_data->evt_list) {
-		list_del(cursor);
-		list_add(cursor, &efx->ptp_data->evt_free_list);
+		list_move(cursor, &efx->ptp_data->evt_free_list);
 	}
 	spin_unlock_bh(&efx->ptp_data->evt_lock);
 
