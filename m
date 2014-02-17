From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH] ethtool: check the ethtool_ops is NULL in dev_ethtool
Date: Mon, 17 Feb 2014 19:31:56 +0800
Message-ID: <5301F32C.4040704@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:25353 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555AbaBQLcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 06:32:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

some drivers maybe not implement the ethtool_ops with only
set NULL. So when call the ethtool cmds will lead to a 
'NULL pointer dereference'.

So add a checking in dev_ethtool.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/core/ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 30071de..f418dcb 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1499,6 +1499,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 	}
+	
+	if (!dev->ethtool_ops)
+		return -EOPNOTSUPP;
 
 	if (dev->ethtool_ops->begin) {
 		rc = dev->ethtool_ops->begin(dev);
-- 
1.7.12
