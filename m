From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: [PATCH] qla3xxx: convert byte order of constant instead of variable
Date: Tue, 25 Dec 2007 15:48:56 +0100
Message-ID: <20071225144852.GB24373@joi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-driver@qlogic.com, LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753510AbXLYOrX@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

convert byte order of constant instead of variable
it will be done at compile time (vs run time)

Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
---
 drivers/net/qla3xxx.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index a579111..c9f8ba4 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2497,8 +2497,7 @@ static int ql_send_map(struct ql3_adapter *qdev,

 	if (seg_cnt == 1) {
 		/* Terminate the last segment. */
-		oal_entry->len =
-		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
+		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
 	} else {
 		oal = tx_cb->oal;
 		for (completed_segs=0; completed_segs<frag_cnt; completed_segs++,seg++) {
@@ -2555,8 +2554,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 					  frag->size);
 		}
 		/* Terminate the last segment. */
-		oal_entry->len =
-		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
+		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
 	}

 	return NETDEV_TX_OK;
--
1.5.3.4

