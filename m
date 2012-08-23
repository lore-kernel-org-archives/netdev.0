From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] w5300: using eth_hw_addr_random() for random MAC and
 set device flag
Date: Thu, 23 Aug 2012 15:28:40 +0800
Message-ID: <CAPgLHd-v=M6QrhT3YnTqUXWqyUa3TgVtNN3Cao1sPXd7stAEww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:64982 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756692Ab2HWH2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 03:28:41 -0400
Received: by qcro28 with SMTP id o28so283687qcr.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 00:28:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using eth_hw_addr_random() to generate a random Ethernet address
(MAC) to be used by a net device and set addr_assign_type.
Not need to duplicating its implementation.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/wiznet/w5300.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index bdd8891..88943d9 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -557,8 +557,7 @@ static int __devinit w5300_hw_probe(struct platform_device *pdev)
 	if (data && is_valid_ether_addr(data->mac_addr)) {
 		memcpy(ndev->dev_addr, data->mac_addr, ETH_ALEN);
 	} else {
-		eth_random_addr(ndev->dev_addr);
-		ndev->addr_assign_type |= NET_ADDR_RANDOM;
+		eth_hw_addr_random(ndev);
 	}
 
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
