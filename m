From: Milan Kocian <milon@wq.cz>
Subject: [PATCH 1/1] ipv6: corrects sended rtnetlink message
Date: Wed, 15 Aug 2007 16:33:22 +0200
Message-ID: <20070815143322.GA25640@wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-sitel.lam.cz ([212.71.129.172]:48118 "EHLO nt.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761834AbXHOOzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 10:55:07 -0400
Received: from milon by nt.wq.cz with local (Exim 4.67)
	(envelope-from <milon@wq.cz>)
	id 1ILJw2-0006uI-Iu
	for netdev@vger.kernel.org; Wed, 15 Aug 2007 16:33:22 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipv6 sends a RTM_DELLINK netlink message on both events: NETDEV_DOWN,
NETDEV_UNREGISTER. Corrected by sending RTM_NEWLINK on NETDEV_DOWN event
and RTM_DELLINK on NETDEV_UNREGISTER event.
---

btw. I don't know why protocol sends a NL messages about iface state
changes. It comes from other sources. By contrast ipv6 doesn't send
no message on NETDEV_UP event !? IMO best possibility is deletion of
sending this message.


--- a/net/ipv6/addrconf.c	2007-08-13 11:35:23.481430029 +0200
+++ b/net/ipv6/addrconf.c	2007-08-13 12:47:01.825690662 +0200
@@ -2488,7 +2488,10 @@ static int addrconf_ifdown(struct net_de
 
 	/* Step 5: netlink notification of this interface */
 	idev->tstamp = jiffies;
-	inet6_ifinfo_notify(RTM_DELLINK, idev);
+	if (how)
+		inet6_ifinfo_notify(RTM_DELLINK, idev);
+	else 
+		inet6_ifinfo_notify(RTM_NEWLINK, idev);
 
 	/* Shot the device (if unregistered) */
 

Signed-off-by: Milan Kocian <milon@wq.cz>
