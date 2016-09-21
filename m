From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH iproute2 2/3] Update inet_diag.h to include INET_DIAG_BBRINFO and related structs
Date: Tue, 20 Sep 2016 22:43:43 -0400
Message-ID: <1474425824-22646-2-git-send-email-ncardwell@google.com>
References: <1474425824-22646-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:33053 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754843AbcIUCns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 22:43:48 -0400
Received: by mail-qt0-f176.google.com with SMTP id 11so16724052qtc.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 19:43:48 -0700 (PDT)
In-Reply-To: <1474425824-22646-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update to include the the inet_diag.h changes in:
  "tcp_bbr: add BBR congestion control"

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/linux/inet_diag.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 5dac049..529a5a2 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -117,6 +117,7 @@ enum {
 	INET_DIAG_PEERS,
 	INET_DIAG_PAD,
 	INET_DIAG_MARK,
+	INET_DIAG_BBRINFO,
 	__INET_DIAG_MAX,
 };
 
@@ -150,8 +151,20 @@ struct tcp_dctcp_info {
 	__u32	dctcp_ab_tot;
 };
 
+/* INET_DIAG_BBRINFO */
+
+struct tcp_bbr_info {
+	/* u64 bw: max-filtered BW (app throughput) estimate in Byte per sec: */
+	__u32	bbr_bw_lo;		/* lower 32 bits of bw */
+	__u32	bbr_bw_hi;		/* upper 32 bits of bw */
+	__u32	bbr_min_rtt;		/* min-filtered RTT in uSec */
+	__u32	bbr_pacing_gain;	/* pacing gain shifted left 8 bits */
+	__u32	bbr_cwnd_gain;		/* cwnd gain shifted left 8 bits */
+};
+
 union tcp_cc_info {
 	struct tcpvegas_info	vegas;
 	struct tcp_dctcp_info	dctcp;
+	struct tcp_bbr_info	bbr;
 };
 #endif /* _INET_DIAG_H_ */
-- 
2.8.0.rc3.226.g39d4020
