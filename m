From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 03/25] sja1000: don't use [delayed_]work_pending()
Date: Fri, 21 Dec 2012 17:56:53 -0800
Message-ID: <1356141435-17340-4-git-send-email-tj@kernel.org>
References: <1356141435-17340-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1356141435-17340-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no need to test whether a (delayed) work item in pending
before queueing, flushing or cancelling it.  Most uses are unnecessary
and quite a few of them are buggy.

Remove unnecessary pending tests from sja1000.  Only compile tested.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
Please let me know how this patch should be routed.  I can take it
through the workqueue tree if necessary.

Thanks.

 drivers/net/can/sja1000/peak_pci.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index d84888f..600ac72 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -339,8 +339,7 @@ static void peak_pciec_set_leds(struct peak_pciec_card *card, u8 led_mask, u8 s)
  */
 static void peak_pciec_start_led_work(struct peak_pciec_card *card)
 {
-	if (!delayed_work_pending(&card->led_work))
-		schedule_delayed_work(&card->led_work, HZ);
+	schedule_delayed_work(&card->led_work, HZ);
 }
 
 /*
-- 
1.8.0.2
