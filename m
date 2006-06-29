From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 3/9] pcnet32: Fix off-by-one in get_ringparam
Date: Thu, 29 Jun 2006 13:53:23 -0700
Message-ID: <20060629205323.GA22001@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:34973 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932512AbWF2UxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 16:53:09 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5TKr81S004790
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:53:08 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5TKr8Wp291086
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:53:08 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5TKr7jj020268
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:53:08 -0400
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix off-by-one in pcnet32_get_ringparam

Signed-off-by:  Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.17-git13/drivers/net/device.pcnet32.c	Wed Jun 28 11:12:22 2006
+++ linux-2.6.17-git13/drivers/net/pcnet32.c	Wed Jun 28 11:16:15 2006
@@ -515,10 +515,10 @@ static void pcnet32_get_ringparam(struct
 {
 	struct pcnet32_private *lp = dev->priv;
 
-	ering->tx_max_pending = TX_MAX_RING_SIZE - 1;
-	ering->tx_pending = lp->tx_ring_size - 1;
-	ering->rx_max_pending = RX_MAX_RING_SIZE - 1;
-	ering->rx_pending = lp->rx_ring_size - 1;
+	ering->tx_max_pending = TX_MAX_RING_SIZE;
+	ering->tx_pending = lp->tx_ring_size;
+	ering->rx_max_pending = RX_MAX_RING_SIZE;
+	ering->rx_pending = lp->rx_ring_size;
 }
 
 static int pcnet32_set_ringparam(struct net_device *dev,
-- 
Don Fry
brazilnut@us.ibm.com
