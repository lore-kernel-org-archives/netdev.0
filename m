From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] atmel: fix netdev ops conversion
Date: Tue, 21 Apr 2009 11:05:20 +0200
Message-ID: <1240304720.17388.13.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:37778 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128AbZDUJF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 05:05:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sparse says:

drivers/net/wireless/atmel.c:1501:3: warning: Initializer entry defined twice
drivers/net/wireless/atmel.c:1505:3:   also defined here

and it's correct; atmel has its own ndo_change_mtu and
shouldn't use eth_change_mtu.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
---
It looks like you (davem) took the initial conversion, do you want this
one as well?

 drivers/net/wireless/atmel.c |    1 -
 1 file changed, 1 deletion(-)

--- wireless-testing.orig/drivers/net/wireless/atmel.c	2009-04-21 11:01:20.000000000 +0200
+++ wireless-testing/drivers/net/wireless/atmel.c	2009-04-21 11:01:22.000000000 +0200
@@ -1500,11 +1500,10 @@ static const struct net_device_ops atmel
 	.ndo_stop		= atmel_close,
 	.ndo_change_mtu 	= atmel_change_mtu,
 	.ndo_set_mac_address 	= atmel_set_mac_address,
 	.ndo_start_xmit 	= start_tx,
 	.ndo_do_ioctl 		= atmel_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
 struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 				   const AtmelFWType fw_type,


