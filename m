From: leitao@linux.vnet.ibm.com
Subject: [PATCH] ehea: Fixing some message level
Date: Thu, 16 Dec 2010 17:13:12 -0200
Message-ID: <1292526792-28901-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:46768 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574Ab0LPTNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 14:13:19 -0500
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp03.br.ibm.com (8.14.4/8.13.1) with ESMTP id oBGJUR0o028275
	for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 17:30:27 -0200
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBGJKTvl1257592
	for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 17:20:29 -0200
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBGJCx6Y027853
	for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 17:12:59 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there are some info message that is set as error, and an error
message that is set as debug. This patch just fixes it.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 0dfef6d..1032b5b 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -740,13 +740,13 @@ static int ehea_proc_rwqes(struct net_device *dev,
 							  skb_arr_rq1_len,
 							  wqe_index);
 				if (unlikely(!skb)) {
-					netif_err(port, rx_err, dev,
+					netif_info(port, rx_err, dev,
 						  "LL rq1: skb=NULL\n");
 
 					skb = netdev_alloc_skb(dev,
 							       EHEA_L_PKT_SIZE);
 					if (!skb) {
-						netdev_info(dev, "Not enough memory to allocate skb\n");
+						netdev_err(dev, "Not enough memory to allocate skb\n");
 						break;
 					}
 				}
-- 
1.7.1

