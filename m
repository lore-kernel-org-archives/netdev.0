From: Xie Jianhua <Jianhua.Xie@freescale.com>
Subject: [PATCH net] bonding: enhance L2 hash helper with packet type
Date: Mon, 14 Jul 2014 14:05:26 +0800
Message-ID: <1405317926-27221-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jianhua Xie <jianhua.xie@freescale.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Pan Jiafei <Jiafei.Pan@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0209.outbound.protection.outlook.com ([207.46.163.209]:37090
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751325AbaGNGLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2014 02:11:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianhua Xie <jianhua.xie@freescale.com>

Current L2 hash helper calculates destination eth addr and
source ether addr as L2 hash factors. This patch is adding
packet type ID field into hash factors, which can help to
distribute different types of packets like IPv4/IPv6 packets
to different slave devices while only BOND_XMIT_POLICY_LAYER2
is applied.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>
CC: Pan Jiafei <Jiafei.Pan@freescale.com>

Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3a451b6..4a72c2f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3002,7 +3002,7 @@ static inline u32 bond_eth_hash(struct sk_buff *skb)
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 
 	if (skb_headlen(skb) >= offsetof(struct ethhdr, h_proto))
-		return data->h_dest[5] ^ data->h_source[5];
+		return data->h_dest[5] ^ data->h_source[5] ^ data->h_proto;
 
 	return 0;
 }
-- 
1.8.5
