From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 06/13] staging: r8188eu: Remove get_recvframe_len()
Date: Fri, 14 Feb 2014 16:54:10 -0600
Message-ID: <1392418457-3203-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jes Sorensen <Jes.Sorensen@redhat.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:52971 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993AbaBNWyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:54:50 -0500
Received: by mail-oa0-f43.google.com with SMTP id h16so15400737oag.30
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 14:54:49 -0800 (PST)
In-Reply-To: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This simple routine is replaced by a simple access of the len member.

Reported-by: Jes Sorensen <Jes.Sorensen@redhat.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
---
 drivers/staging/rtl8188eu/core/rtw_recv.c    | 2 +-
 drivers/staging/rtl8188eu/include/rtw_recv.h | 5 -----
 2 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 1e40eba..d174a6c 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -743,7 +743,7 @@ static void count_rx_stats(struct adapter *padapter,
 	struct rx_pkt_attrib	*pattrib = &prframe->attrib;
 	struct recv_priv	*precvpriv = &padapter->recvpriv;
 
-	sz = get_recvframe_len(prframe);
+	sz = prframe->len;
 	precvpriv->rx_bytes += sz;
 
 	padapter->mlmepriv.LinkDetectInfo.NumRxOkInPeriod++;
diff --git a/drivers/staging/rtl8188eu/include/rtw_recv.h b/drivers/staging/rtl8188eu/include/rtw_recv.h
index 2159639..1f4d984 100644
--- a/drivers/staging/rtl8188eu/include/rtw_recv.h
+++ b/drivers/staging/rtl8188eu/include/rtw_recv.h
@@ -406,11 +406,6 @@ static inline u8 *recvframe_pull_tail(struct recv_frame *precvframe, int sz)
 	return precvframe->rx_tail;
 }
 
-static inline int get_recvframe_len(struct recv_frame *precvframe)
-{
-	return precvframe->len;
-}
-
 static inline s32 translate_percentage_to_dbm(u32 sig_stren_index)
 {
 	s32	power; /*  in dBm. */
-- 
1.8.4.5
