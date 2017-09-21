From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 1/2] dummy: add device MTU validation check
Date: Thu, 21 Sep 2017 21:32:01 +0800
Message-ID: <1506000722-40095-2-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1506000722-40095-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, willemb@google.com,
        stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:12409 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751718AbdIUNcX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 09:32:23 -0400
In-Reply-To: <1506000722-40095-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, any mtu value can be assigned when adding a new dummy device:
[~]# ip link add name dummy1 mtu 100000 type dummy
[~]# ip link show dummy1
15: dummy1: <BROADCAST,NOARP> mtu 100000 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 0a:61:6b:16:14:ce brd ff:ff:ff:ff:ff:ff

This patch adds device MTU validation check.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/dummy.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index e31ab3b..0276b2b 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -365,6 +365,14 @@ static int dummy_validate(struct nlattr *tb[], struct nlattr *data[],
 		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
+
+	if (tb[IFLA_MTU]) {
+		u32 mtu = nla_get_u32(tb[IFLA_MTU]);
+
+		if (mtu > ETH_MAX_MTU)
+			return -EINVAL;
+	}
+
 	return 0;
 }
 
-- 
1.8.3.1
