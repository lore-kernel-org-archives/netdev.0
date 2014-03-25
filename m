From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 2/2] bonding: ratelimit pr_err() for bond xmit broadcast
Date: Tue, 25 Mar 2014 17:00:10 +0800
Message-ID: <1395738010-12212-3-git-send-email-dingtianhong@huawei.com>
References: <1395738010-12212-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<joe@perches.com>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:16036 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbaCYJGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 05:06:09 -0400
In-Reply-To: <1395738010-12212-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It may spam if the system is out of the memory, add ratelimit for it.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ee17c24..52c4c77 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3656,8 +3656,8 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
 			if (!skb2) {
-				pr_err("%s: Error: bond_xmit_broadcast(): skb_clone() failed\n",
-				       bond_dev->name);
+				net_err_ratelimited("%s: Error: %s: skb_clone() failed\n",
+						    bond_dev->name, __func__);
 				continue;
 			}
 			/* bond_dev_queue_xmit always returns 0 */
-- 
1.8.0
