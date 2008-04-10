From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
	prior to interface-up
Date: Thu, 10 Apr 2008 17:00:17 +0200
Message-ID: <1207839617.4311.6.camel@compaq.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@redhat.com>
To: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out0.tiscali.nl ([195.241.79.175]:33041 "EHLO
	smtp-out0.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755698AbYDJPCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 11:02:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>
   
Commit bada339 (Validate device addr prior to interface-up) caused a regression
in the ISDN network code, see: http://bugzilla.kernel.org/show_bug.cgi?id=9923
The trivial fix is to remove the pointer to eth_validate_addr() in the
net_device struct in isdn_net_init().
    
Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Please note that I hardly know what the device address validation is good for.
Neither do I know much about the ISDN network code or why the device address
validation fails for ISDN interfaces. This patch however basically reverts 
commit bada339 just for the ISDN network code. I can't think of any side
effects.

http://bugzilla.kernel.org/show_bug.cgi?id=9923 would have been much easier to
track down if eth_validate_addr() would somehow complain aloud if an address 
is invalid. Shouldn't it make at least some noise?

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index ced83c2..ef1a300 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -2010,6 +2010,7 @@ isdn_net_init(struct net_device *ndev)
 	ndev->flags = IFF_NOARP|IFF_POINTOPOINT;
 	ndev->type = ARPHRD_ETHER;
 	ndev->addr_len = ETH_ALEN;
+	ndev->validate_addr = NULL;
 
 	/* for clients with MPPP maybe higher values better */
 	ndev->tx_queue_len = 30;

