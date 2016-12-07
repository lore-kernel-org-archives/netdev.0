From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next v2] dummy: extend mtu range for dummy device
Date: Wed,  7 Dec 2016 19:56:59 +0800
Message-ID: <1481111819-2992-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: jarod@redhat.com, netdev@vger.kernel.org,
        sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:19232 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750953AbcLGL5b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 06:57:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 61e84623ace3 ("net: centralize net_device min/max MTU checking"),
the mtu range for dummy device becomes [68, 1500].

This patch extends it to [0, 65535].

v2
 - fix typo in commit message

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/dummy.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 69fc840..6421835 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -154,6 +154,9 @@ static void dummy_setup(struct net_device *dev)
 	dev->hw_features |= dev->features;
 	dev->hw_enc_features |= dev->features;
 	eth_hw_addr_random(dev);
+
+	dev->min_mtu = 0;
+	dev->max_mtu = ETH_MAX_MTU;
 }
 
 static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
-- 
1.8.3.1
