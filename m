From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: [PATCH resend] qla3xxx: convert byte order of constant instead of
	variable
Date: Sun, 10 Feb 2008 11:06:08 +0100
Message-ID: <20080210100546.GA6737@joi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org, linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:48168 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754395AbYBJKGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 05:06:43 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3437223fga.17
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2008 02:06:40 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

convert byte order of constant instead of variable
which can be done at compile time (vs run time)

Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
---
 drivers/net/qla3xxx.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index a6aeb9d..b7f7b22 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2472,8 +2472,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 
 	if (seg_cnt == 1) {
 		/* Terminate the last segment. */
-		oal_entry->len =
-		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
+		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
 	} else {
 		oal = tx_cb->oal;
 		for (completed_segs=0; completed_segs<frag_cnt; completed_segs++,seg++) {
@@ -2530,8 +2529,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 					  frag->size);
 		}
 		/* Terminate the last segment. */
-		oal_entry->len =
-		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
+		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
 	}
 
 	return NETDEV_TX_OK;
-- 
1.5.3.7

