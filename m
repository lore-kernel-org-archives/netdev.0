From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix missing operation in spider_net
Date: Mon, 23 Mar 2009 14:43:25 -0700 (PDT)
Message-ID: <20090323.144325.34375219.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53050
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751706AbZCWVni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 17:43:38 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 05683C8D98C
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 14:43:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen's review of my sparc driver conversions made me
remember that spider_net missed one of these as well.

Fixed thusly:

spider_net: Add missing .ndo_validate_addr

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/spider_net.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 0288054..90e663f 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -2268,6 +2268,7 @@ static const struct net_device_ops spider_net_ops = {
 	.ndo_change_mtu		= spider_net_change_mtu,
 	.ndo_do_ioctl		= spider_net_do_ioctl,
 	.ndo_tx_timeout		= spider_net_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
 	/* HW VLAN */
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	/* poll controller */
-- 
1.6.2.1.222.g570cc

