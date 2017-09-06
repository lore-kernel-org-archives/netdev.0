From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH v2 net-next 2/2] hv_netvsc: avoid unnecessary wakeups on subchannel creation
Date: Wed,  6 Sep 2017 13:53:06 -0700
Message-ID: <20170906205306.10541-3-sthemmin@microsoft.com>
References: <20170906205306.10541-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34557 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753242AbdIFUxS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 16:53:18 -0400
Received: by mail-pf0-f171.google.com with SMTP id e1so583448pfk.1
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 13:53:18 -0700 (PDT)
In-Reply-To: <20170906205306.10541-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only need to wakeup the initiator after all sub-channels
are opened.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/rndis_filter.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 731bc7cc6f43..065b204d8e17 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1048,8 +1048,8 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 	else
 		netdev_notice(ndev, "sub channel open failed: %d\n", ret);
 
-	atomic_inc(&nvscdev->open_chn);
-	wake_up(&nvscdev->subchan_open);
+	if (atomic_inc_return(&nvscdev->open_chn) == nvscdev->num_chn)
+		wake_up(&nvscdev->subchan_open);
 }
 
 /* Open sub-channels after completing the handling of the device probe.
-- 
2.11.0
