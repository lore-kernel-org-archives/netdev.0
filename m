From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/3] bluetooth: 6lowpan dev_close never returns error
Date: Tue, 18 Jul 2017 15:59:25 -0700
Message-ID: <20170718225927.15944-2-sthemmin@microsoft.com>
References: <20170718225927.15944-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        davem@davemloft.net, marcel@holtmann.org, gustavo@padovan.org,
        johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35343 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751995AbdGRW7c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 18:59:32 -0400
Received: by mail-pf0-f180.google.com with SMTP id e199so17990677pfh.2
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 15:59:32 -0700 (PDT)
In-Reply-To: <20170718225927.15944-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function dev_close in current kernel will never return an
error. Later changes will make it void.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/bluetooth/6lowpan.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index ab3b654b05cc..e542b8959d88 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -621,9 +621,7 @@ static void ifdown(struct net_device *netdev)
 	int err;
 
 	rtnl_lock();
-	err = dev_close(netdev);
-	if (err < 0)
-		BT_INFO("iface %s cannot be closed (%d)", netdev->name, err);
+	dev_close(netdev);
 	rtnl_unlock();
 }
 
-- 
2.11.0
