From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 1/1] [DCCP]: Tidyup CCID3 list handling
Date: Mon, 28 Aug 2006 16:36:37 +1200
Message-ID: <200608281636.38517.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:51696 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932327AbWH1EhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 00:37:20 -0400
Received: by py-out-1112.google.com with SMTP id n25so2323615pyg
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 21:37:20 -0700 (PDT)
To: David Miller <davem@davemloft.net>,
	Arnaldo de Melo <arnaldo.melo@gmail.com>,
	"DCCP (vger)" <dccp@vger.kernel.org>,
	"netdev, " <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As Arnaldo Carvalho de Melo points out I should be using list_entry in case
the structure changes in future. Current code functions but is reliant
on position and requires type cast.

Noticed when doing this that I have one more variable than I needed so
removing that also.

Signed off by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 090bc39..195aa95 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -900,7 +900,7 @@ found:
 static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_li_hist_entry *next, *head;
+	struct dccp_li_hist_entry *head;
 	u64 seq_temp;
 
 	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
@@ -908,15 +908,15 @@ static void ccid3_hc_rx_update_li(struct
 		   &hcrx->ccid3hcrx_li_hist, seq_loss, win_loss))
 			return;
 
-		next = (struct dccp_li_hist_entry *)
-		   hcrx->ccid3hcrx_li_hist.next;
-		next->dccplih_interval = ccid3_hc_rx_calc_first_li(sk);
+		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
+		   struct dccp_li_hist_entry, dccplih_node);
+		head->dccplih_interval = ccid3_hc_rx_calc_first_li(sk);
 	} else {
 		struct dccp_li_hist_entry *entry;
 		struct list_head *tail;
 
-		head = (struct dccp_li_hist_entry *)
-		   hcrx->ccid3hcrx_li_hist.next;
+		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
+		   struct dccp_li_hist_entry, dccplih_node);
 		/* FIXME win count check removed as was wrong */
 		/* should make this check with receive history */
 		/* and compare there as per section 10.2 of RFC4342 */
