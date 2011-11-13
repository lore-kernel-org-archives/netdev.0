From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v3 net-next 11/12] bnx2x: Remove on-stack napi struct
 variable
Date: Sun, 13 Nov 2011 16:34:31 +0200
Message-ID: <1321194872-8276-12-git-send-email-dmitry@broadcom.com>
References: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1899 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754175Ab1KMOfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 09:35:05 -0500
In-Reply-To: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index e9a91a3..13dad92 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -79,19 +79,21 @@ static inline void bnx2x_bz_fp(struct bnx2x *bp, int index)
  * @to:		destination FP index
  *
  * Makes sure the contents of the bp->fp[to].napi is kept
- * intact.
+ * intact. This is done by first copying the napi struct from
+ * the target to the source, and then mem copying the entire
+ * source onto the target
  */
 static inline void bnx2x_move_fp(struct bnx2x *bp, int from, int to)
 {
 	struct bnx2x_fastpath *from_fp = &bp->fp[from];
 	struct bnx2x_fastpath *to_fp = &bp->fp[to];
-	struct napi_struct orig_napi = to_fp->napi;
+
+	/* Copy the NAPI object as it has been already initialized */
+	from_fp->napi = to_fp->napi;
+
 	/* Move bnx2x_fastpath contents */
 	memcpy(to_fp, from_fp, sizeof(*to_fp));
 	to_fp->index = to;
-
-	/* Restore the NAPI object as it has been already initialized */
-	to_fp->napi = orig_napi;
 }
 
 int load_count[2][3] = { {0} }; /* per-path: 0-common, 1-port0, 2-port1 */
-- 
1.7.7.2
