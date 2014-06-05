From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/4] net: dev: don't set the same mac address for netdev
Date: Thu, 5 Jun 2014 14:50:26 +0800
Message-ID: <1401951028-9800-3-git-send-email-dingtianhong@huawei.com>
References: <1401951028-9800-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>, <edumazet@google.com>,
	<vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:25973 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbaFEGvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 02:51:25 -0400
In-Reply-To: <1401951028-9800-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of netdev just like bond, team, vlan will set the mac address
and propagate to the upperdev or lowerdev regardless the mac address
is  same or not, I could not find that the same mac address could
make affect, so add equal check when set mac address.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/core/dev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5367bfb..4008a51 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5570,6 +5570,8 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 		return -EINVAL;
 	if (!netif_device_present(dev))
 		return -ENODEV;
+	if (ether_addr_equal_64bits(dev->dev_addr, sa->sa_data))
+		return 0;
 	err = ops->ndo_set_mac_address(dev, sa);
 	if (err)
 		return err;
-- 
1.8.0
