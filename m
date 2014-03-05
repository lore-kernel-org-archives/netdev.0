From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 05/13] r8152: check tx agg list before spin lock
Date: Wed, 5 Mar 2014 14:49:20 +0800
Message-ID: <1394002168-3193-6-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1394002168-3193-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394002168-3193-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check tx agg list before spin lock to avoid doing spin lock every
times.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 8ecb41b..00b3192 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1266,6 +1266,9 @@ static struct tx_agg *r8152_get_tx_agg(struct r8152 *tp)
 	struct tx_agg *agg = NULL;
 	unsigned long flags;
 
+	if (list_empty(&tp->tx_free))
+		return NULL;
+
 	spin_lock_irqsave(&tp->tx_lock, flags);
 	if (!list_empty(&tp->tx_free)) {
 		struct list_head *cursor;
-- 
1.8.4.2
