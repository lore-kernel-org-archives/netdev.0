From: Colin King <colin.king@canonical.com>
Subject: [PATCH] cxgb4: fix memory leak of qe on error exit path
Date: Sun, 16 Oct 2016 23:54:03 +0100
Message-ID: <20161016225403.4108-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

A memory leak of qe occurs when t4_sched_queue_unbind fails,
so fix this by free'ing qe on the error exit path.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sched.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sched.c b/drivers/net/ethernet/chelsio/cxgb4/sched.c
index 539de76..cbd68a8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sched.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sched.c
@@ -210,8 +210,10 @@ static int t4_sched_queue_bind(struct port_info *pi, struct ch_sched_queue *p)
 
 	/* Unbind queue from any existing class */
 	err = t4_sched_queue_unbind(pi, p);
-	if (err)
+	if (err) {
+		t4_free_mem(qe);
 		goto out;
+	}
 
 	/* Bind queue to specified class */
 	memset(qe, 0, sizeof(*qe));
-- 
2.9.3
