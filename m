From: Pan Bian <bianpan201603@163.com>
Subject: [PATCH 1/1] net: ethernet: qlogic: set error code on failure
Date: Sun,  4 Dec 2016 13:53:53 +0800
Message-ID: <1480830833-5084-1-git-send-email-bianpan201603@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016@163.com>

When calling dma_mapping_error(), the value of return variable rc is 0.
And when the call returns an unexpected value, rc is not set to a
negative errno. Thus, it will return 0 on the error path, and its
callers cannot detect the bug. This patch fixes the bug, assigning
"-ENOMEM" to err.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=189041

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index f95385c..62ae55b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -1730,6 +1730,7 @@ static int qed_ll2_start_xmit(struct qed_dev *cdev, struct sk_buff *skb)
 						       mapping))) {
 				DP_NOTICE(cdev,
 					  "Unable to map frag - dropping packet\n");
+				rc = -ENOMEM;
 				goto err;
 			}
 		} else {
-- 
1.9.1
