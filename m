From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 11/11] r8152: replace napi_complete with napi_complete_done
Date: Fri, 9 Jun 2017 17:11:48 +0800
Message-ID: <1394712342-15778-271-Taiwan-albertk@realtek.com>
References: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change from using napi_complete to napi_complete_done to allow for the
use of gro_flush_timeout in tuning network processing.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index fa29583..5a02053 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1938,7 +1938,8 @@ static int r8152_poll(struct napi_struct *napi, int budget)
 	bottom_half(tp);
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		if (!napi_complete_done(napi, work_done))
+			goto out;
 		if (!list_empty(&tp->rx_done))
 			napi_schedule(napi);
 		else if (!skb_queue_empty(&tp->tx_queue) &&
@@ -1946,6 +1947,7 @@ static int r8152_poll(struct napi_struct *napi, int budget)
 			napi_schedule(napi);
 	}
 
+out:
 	return work_done;
 }
 
-- 
2.7.4
