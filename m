From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: ena: use setup_timer() and mod_timer()
Date: Sat, 22 Oct 2016 14:36:36 +0000
Message-ID: <1477146996-2536-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Netanel Belgazal <netanel@annapurnalabs.com>,
        Saeed Bishara <saeed@annapurnalabs.com>,
        Zorik Machulsky <zorik@annapurnalabs.com>,
        "David S. Miller" <davem@davemloft.net>,
        Wei Yongjun <weiyj.lk@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36054 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934263AbcJVOgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 10:36:46 -0400
Received: by mail-pf0-f194.google.com with SMTP id r16so11486263pfg.3
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2016 07:36:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Use setup_timer() instead of init_timer(), being the preferred/standard
way to set a timer up.

Also, quoting the mod_timer() function comment:
-> mod_timer() is a more efficient way to update the expire field of an
   active timer (if the timer is inactive it will be activated).

Use setup_timer and mod_timer to setup and arm a timer, to make the code
cleaner and easier to read.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 2a55ab0..cc8b13e 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -3013,12 +3013,9 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	adapter->last_keep_alive_jiffies = jiffies;
 
-	init_timer(&adapter->timer_service);
-	adapter->timer_service.expires = round_jiffies(jiffies + HZ);
-	adapter->timer_service.function = ena_timer_service;
-	adapter->timer_service.data = (unsigned long)adapter;
-
-	add_timer(&adapter->timer_service);
+	setup_timer(&adapter->timer_service, ena_timer_service,
+		    (unsigned long)adapter);
+	mod_timer(&adapter->timer_service, round_jiffies(jiffies + HZ));
 
 	dev_info(&pdev->dev, "%s found at mem %lx, mac addr %pM Queues %d\n",
 		 DEVICE_NAME, (long)pci_resource_start(pdev, 0),
