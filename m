From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH] cxgb3: fix hot plug removal crash
Date: Wed, 03 Mar 2010 11:49:47 -0800
Message-ID: <20100303194947.31628.5933.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, wenxiong@us.ibm.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

queue restart tasklets need to be stopped after napi handlers are stopped
since the latter can restart them.  So stop them after stopping napi.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 6fd968a..cecdec1 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1280,6 +1280,7 @@ static void cxgb_down(struct adapter *adapter)
 
 	free_irq_resources(adapter);
 	quiesce_rx(adapter);
+	t3_sge_stop(adapter);
 	flush_workqueue(cxgb3_wq);	/* wait for external IRQ handler */
 }
 
