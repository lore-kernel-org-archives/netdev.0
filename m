From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH 2/2] net: spider_net: avoid using signed char for bitops
Date: Fri,  3 Oct 2014 17:01:56 +0200
Message-ID: <1412348517-20352-4-git-send-email-antoine.tenart@free-electrons.com>
References: <1412348517-20352-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dan.carpenter@oracle.com, kou.ishizaki@toshiba.co.jp,
	jens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:46682 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752725AbaJCPCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:02:01 -0400
In-Reply-To: <1412348517-20352-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signedness bugs may occur when using signed char for bitops,
depending on if the highest bit is ever used.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/toshiba/spider_net.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 713313e15c68..8e9371a3388a 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -1325,9 +1325,9 @@ spider_net_set_mac(struct net_device *netdev, void *p)
 	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD, regvalue);
 
 	/* write mac */
-	macu = (addr->sa_data[0]<<24) + (addr->sa_data[1]<<16) +
-		(addr->sa_data[2]<<8) + (addr->sa_data[3]);
-	macl = (addr->sa_data[4]<<8) + (addr->sa_data[5]);
+	macu = (netdev->dev_addr[0]<<24) + (netdev->dev_addr[1]<<16) +
+		(netdev->dev_addr[2]<<8) + (netdev->dev_addr[3]);
+	macl = (netdev->dev_addr[4]<<8) + (netdev->dev_addr[5]);
 	spider_net_write_reg(card, SPIDER_NET_GMACUNIMACU, macu);
 	spider_net_write_reg(card, SPIDER_NET_GMACUNIMACL, macl);
 
-- 
1.9.1
