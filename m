From: leitao@linux.vnet.ibm.com
Subject: [PATCH] ehea: Avoid changing vlan flags
Date: Mon, 20 Dec 2010 17:02:37 -0200
Message-ID: <1292871757-24918-1-git-send-email-leitao@linux.vnet.ibm.com>
References: <AANLkTimODzrAWS+05+FChtme_3um_9Ky7cwa3gWHFaXp@mail.gmail.com>
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, jesse@nicira.com,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:38236 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932682Ab0LTTCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 14:02:44 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id oBKJPksZ005240
	for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 17:25:46 -0200
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBKJ18RA1347776
	for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 16:01:08 -0300
Received: from d24av03.br.ibm.com (loopback [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBKJ2dem017094
	for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 17:02:40 -0200
In-Reply-To: <AANLkTimODzrAWS+05+FChtme_3um_9Ky7cwa3gWHFaXp@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch avoids disabling the vlan flags using ethtool.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea_ethtool.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index afebf20..3e2e734 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -265,6 +265,13 @@ static void ehea_get_ethtool_stats(struct net_device *dev,
 
 static int ehea_set_flags(struct net_device *dev, u32 data)
 {
+	/* Avoid changing the VLAN flags */
+	if ((data & (ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN)) !=
+	    (ethtool_op_get_flags(dev) & (ETH_FLAG_RXVLAN |
+					  ETH_FLAG_TXVLAN))){
+		return -EINVAL;
+	}
+
 	return ethtool_op_set_flags(dev, data, ETH_FLAG_LRO
 					| ETH_FLAG_TXVLAN
 					| ETH_FLAG_RXVLAN);
-- 
1.7.3.3

