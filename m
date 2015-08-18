From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 4/4] vrf: simplify the netdev notifier function
Date: Tue, 18 Aug 2015 20:28:04 +0300
Message-ID: <1439918884-13681-5-git-send-email-razor@blackwall.org>
References: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36565 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753915AbbHRT3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 15:29:13 -0400
Received: by wicja10 with SMTP id ja10so102836453wic.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 12:29:12 -0700 (PDT)
In-Reply-To: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

We can drop the check because if vrf_ptr is present then we must have
the vrf device as a master and since we're running with rtnl it can't go
away.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/vrf.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 97605eab14ae..ed208317cbb5 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -624,9 +624,8 @@ static int vrf_device_event(struct notifier_block *unused,
 		if (!vrf_ptr || netif_is_vrf(dev))
 			goto out;
 
-		vrf_dev = __dev_get_by_index(dev_net(dev), vrf_ptr->ifindex);
-		if (vrf_dev)
-			vrf_del_slave(vrf_dev, dev);
+		vrf_dev = netdev_master_upper_dev_get(dev);
+		vrf_del_slave(vrf_dev, dev);
 	}
 out:
 	return NOTIFY_DONE;
-- 
2.4.3
