From: akpm@linux-foundation.org
Subject: [patch 02/17] qla3xxx: convert byte order of constant instead of variable
Date: Tue, 04 Mar 2008 15:19:20 -0800
Message-ID: <200803042319.m24NJKLT002661@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	marcin.slusarz@gmail.com, ron.mercer@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50077 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935064AbYCDXT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcin Slusarz <marcin.slusarz@gmail.com>

Convert byte order of constant instead of variable which can be done at
compile time (vs run time)

Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
Acked-by: Ron Mercer <ron.mercer@qlogic.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/qla3xxx.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff -puN drivers/net/qla3xxx.c~qla3xxx-convert-byte-order-of-constant-instead-of-variable drivers/net/qla3xxx.c
--- a/drivers/net/qla3xxx.c~qla3xxx-convert-byte-order-of-constant-instead-of-variable
+++ a/drivers/net/qla3xxx.c
@@ -2472,8 +2472,7 @@ static int ql_send_map(struct ql3_adapte
 
 	if (seg_cnt == 1) {
 		/* Terminate the last segment. */
-		oal_entry->len =
-		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
+		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
 	} else {
 		oal = tx_cb->oal;
 		for (completed_segs=0; completed_segs<frag_cnt; completed_segs++,seg++) {
@@ -2530,8 +2529,7 @@ static int ql_send_map(struct ql3_adapte
 					  frag->size);
 		}
 		/* Terminate the last segment. */
-		oal_entry->len =
-		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
+		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
 	}
 
 	return NETDEV_TX_OK;
_
