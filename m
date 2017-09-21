From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 2/2] ifb: add device MTU validation check
Date: Thu, 21 Sep 2017 21:32:02 +0800
Message-ID: <1506000722-40095-3-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1506000722-40095-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, willemb@google.com,
        stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:25817 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751617AbdIUNcT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 09:32:19 -0400
In-Reply-To: <1506000722-40095-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, any mtu value can be assigned when adding a new ifb device:
[~]# ip link add name ifb2 mtu 100000 type ifb
[~]# ip link show ifb2
18: ifb2: <BROADCAST,NOARP> mtu 100000 qdisc noop state DOWN mode DEFAULT group default qlen 32
    link/ether 7a:bf:f4:63:da:d1 brd ff:ff:ff:ff:ff:ff

This patch adds device MTU validation check.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/ifb.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 8870bd2..ce84ad2 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -282,6 +282,14 @@ static int ifb_validate(struct nlattr *tb[], struct nlattr *data[],
 		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
+
+	if (tb[IFLA_MTU]) {
+		u32 mtu = nla_get_u32(tb[IFLA_MTU]);
+
+		if (mtu < ETH_MIN_MTU || mtu > ETH_DATA_LEN)
+			return -EINVAL;
+	}
+
 	return 0;
 }
 
-- 
1.8.3.1
