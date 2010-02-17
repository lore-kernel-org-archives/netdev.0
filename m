From: Darren Jenkins <darrenrjenkins@gmail.com>
Subject: [PATCH] drivers/net/wireless/p54/txrx.c Fix off by one error
Date: Wed, 17 Feb 2010 23:40:15 +1100
Message-ID: <1266410415.17837.6.camel@ICE-BOX>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>,
	Christian Lamparter <chunkeey@web.de>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Bob Copeland <me@bobcopeland.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kernel Janitors <kernel-janitors@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f200.google.com ([209.85.210.200]:38003 "EHLO
	mail-yx0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757256Ab0BQMkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 07:40:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix off by one error in the queue size check of p54_tx_qos_accounting_alloc()

Coverity CID: 13314

Signed-off-by: Darren Jenkins <darrenrjenkins@gmail.com>
---
 drivers/net/wireless/p54/txrx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/p54/txrx.c b/drivers/net/wireless/p54/txrx.c
index b6dda2b..9d147de 100644
--- a/drivers/net/wireless/p54/txrx.c
+++ b/drivers/net/wireless/p54/txrx.c
@@ -186,7 +186,7 @@ static int p54_tx_qos_accounting_alloc(struct p54_common *priv,
 	struct ieee80211_tx_queue_stats *queue;
 	unsigned long flags;
 
-	if (WARN_ON(p54_queue > P54_QUEUE_NUM))
+	if (WARN_ON(p54_queue >= P54_QUEUE_NUM))
 		return -EINVAL;
 
 	queue = &priv->tx_stats[p54_queue];
-- 
1.6.3.3



