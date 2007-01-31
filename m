From: Divy Le Ray <None@chelsio.com>
Subject: [PATCH 7/10] cxgb3 - Remove BUG_ON from t3b_intr_napi
Date: Tue, 30 Jan 2007 19:44:18 -0800
Message-ID: <20070131034418.8640.29593.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932794AbXAaDpH@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

In some cases, SG_DATA_INTR won't clear on read and the following 
interrupt may cause us to assert because NAPI is already scheduled. 
Remove the assertion, NAPI can handle attempts to rearm it while
it's already scheduled.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 8b3c824..daef7fd 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2199,14 +2199,12 @@ static irqreturn_t t3b_intr_napi(int irq
 	if (likely(map & 1)) {
 		dev = adap->sge.qs[0].netdev;
 
-		BUG_ON(napi_is_scheduled(dev));
 		if (likely(__netif_rx_schedule_prep(dev)))
 			__netif_rx_schedule(dev);
 	}
 	if (map & 2) {
 		dev = adap->sge.qs[1].netdev;
 
-		BUG_ON(napi_is_scheduled(dev));
 		if (likely(__netif_rx_schedule_prep(dev)))
 			__netif_rx_schedule(dev);
 	}
