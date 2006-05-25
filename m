From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.17-rc5] pcnet32:  remove incorrect pcnet32_free_ring
Date: Thu, 25 May 2006 16:22:40 -0700
Message-ID: <20060525232240.GA30918@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:11961 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S965189AbWEYXWl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 19:22:41 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4PNMcO3007251
	for <netdev@vger.kernel.org>; Thu, 25 May 2006 19:22:38 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4PNMcCM175094
	for <netdev@vger.kernel.org>; Thu, 25 May 2006 17:22:38 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k4PNMc9D017825
	for <netdev@vger.kernel.org>; Thu, 25 May 2006 17:22:38 -0600
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During a code scan for another change I discovered that this call to
pcnet32_free_ring must be removed.  If the open fails due to a lack of
memory all the ring structures are removed via the call to free_ring
and a subsequent call to open will dereference a null pointer in
pcnet32_init_ring.

Please apply to 2.6.17.

Signed-off-by:  Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.17-rc5/drivers/net/orig.pcnet32.c	2006-05-25 15:59:12.000000000 -0700
+++ linux-2.6.17-rc5/drivers/net/pcnet32.c	2006-05-25 16:09:40.000000000 -0700
@@ -1774,8 +1774,6 @@ static int pcnet32_open(struct net_devic
 		lp->rx_dma_addr[i] = 0;
 	}
 
-	pcnet32_free_ring(dev);
-
 	/*
 	 * Switch back to 16bit mode to avoid problems with dumb
 	 * DOS packet driver after a warm reboot

-- 
Don Fry
brazilnut@us.ibm.com
