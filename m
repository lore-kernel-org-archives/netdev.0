From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] vlan: allow creating vlan when real device is not up
Date: Thu, 30 Jul 2009 11:23:21 -0700
Message-ID: <20090730112321.35753739@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34461 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751342AbZG3SX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jul 2009 14:23:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason for the arbitrary restriction that device must be
up to create a vlan. This patch was added to Vyatta kernel to resolve startup
ordering issues where vlan's are created but real device was disabled.

Note: the vlan already correctly inherits the operstate from real device; so
if vlan is created and real device is marked down, the vlan is marked
down.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/8021q/vlan.c	2009-07-30 11:15:34.983190412 -0700
+++ b/net/8021q/vlan.c	2009-07-30 11:16:03.590055942 -0700
@@ -225,12 +225,6 @@ int vlan_check_real_dev(struct net_devic
 		return -EOPNOTSUPP;
 	}
 
-	/* The real device must be up and operating in order to
-	 * assosciate a VLAN device with it.
-	 */
-	if (!(real_dev->flags & IFF_UP))
-		return -ENETDOWN;
-
 	if (__find_vlan_dev(real_dev, vlan_id) != NULL)
 		return -EEXIST;
 
