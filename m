From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 6/6] cxgb4: Combine substrings for two messages
Date: Thu, 4 May 2017 22:36:11 +0200
Message-ID: <5e89d06b-3f3b-2c78-ab7c-40cce15e7f74@users.sourceforge.net>
References: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Casey Leedom <leedom@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 4 May 2017 22:16:57 +0200

The script "checkpatch.pl" pointed information out like the following.

WARNING: quoted string split across lines

Thus fix two source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 32add8dfc253..f9384d8b680d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1353,8 +1353,9 @@ static int mps_trc_show(struct seq_file *seq, void *v)
 	if (tp.port < 8) {
 		i = adap->chan_map[tp.port & 3];
 		if (i >= MAX_NPORTS) {
-			dev_err(adap->pdev_dev, "tracer %u is assigned "
-				"to non-existing port\n", trcidx);
+			dev_err(adap->pdev_dev,
+				"tracer %u is assigned to non-existing port\n",
+				trcidx);
 			return -EINVAL;
 		}
 		seq_printf(seq, "tracer is capturing %s %s, ",
@@ -1798,11 +1799,11 @@ static int mps_tcam_show(struct seq_file *seq, void *v)
 				      FW_LDST_CMD_IDX_V(idx));
 			ret = t4_wr_mbox(adap, adap->mbox, &ldst_cmd,
 					 sizeof(ldst_cmd), &ldst_cmd);
-			if (ret)
-				dev_warn(adap->pdev_dev, "Can't read MPS "
-					 "replication map for idx %d: %d\n",
+			if (ret) {
+				dev_warn(adap->pdev_dev,
+					 "Can't read MPS replication map for idx %d: %d\n",
 					 idx, -ret);
-			else {
+			} else {
 				mps_rplc = ldst_cmd.u.mps.rplc;
 				rplc[0] = ntohl(mps_rplc.rplc31_0);
 				rplc[1] = ntohl(mps_rplc.rplc63_32);
-- 
2.12.2
