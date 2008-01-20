From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/4] dsmark: get rid of trivial function
Date: Sun, 20 Jan 2008 13:25:50 -0800
Message-ID: <20080120132550.056370c0@deepthought>
References: <20080120130542.16720b45@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:38676 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755386AbYATVac (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 16:30:32 -0500
In-Reply-To: <20080120130542.16720b45@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace loop in dsmark_valid_indices with equivalent bit math.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/sch_dsmark.c	2008-01-20 13:07:58.000000000 -0800
+++ b/net/sched/sch_dsmark.c	2008-01-20 13:22:54.000000000 -0800
@@ -45,13 +45,8 @@ struct dsmark_qdisc_data {
 
 static inline int dsmark_valid_indices(u16 indices)
 {
-	while (indices != 1) {
-		if (indices & 1)
-			return 0;
-		indices >>= 1;
-	}
-
-	return 1;
+	/* Must have only one bit set */
+	return (indices & (indices - 1)) == 0;
 }
 
 static inline int dsmark_valid_index(struct dsmark_qdisc_data *p, u16 index)
