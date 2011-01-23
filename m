From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ipv6: why disable ipv6 on last address removal?
Date: Sun, 23 Jan 2011 20:47:45 +1100
Message-ID: <20110123204745.2f4f2de0@s6510>
References: <20091208192046.GA5649@midget.suse.cz>
	<20091208.125611.135547597.davem@davemloft.net>
	<4B1F5423.4070109@linux-ipv6.org>
	<20100104.224436.107234750.davem@davemloft.net>
	<20100216152859.GC29736@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57456 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751374Ab1AWJr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jan 2011 04:47:57 -0500
In-Reply-To: <20100216152859.GC29736@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What about this? It will remove the address on ipv6 disable.

--- a/net/ipv6/addrconf.c	2011-01-23 20:30:25.897243002 +1100
+++ b/net/ipv6/addrconf.c	2011-01-23 20:30:41.161243002 +1100
@@ -4197,7 +4197,7 @@ static void dev_disable_change(struct in
 		return;
 
 	if (idev->cnf.disable_ipv6)
-		addrconf_notify(NULL, NETDEV_DOWN, idev->dev);
+		addrconf_notify(NULL, NETDEV_UNREGISTER, idev->dev);
 	else
 		addrconf_notify(NULL, NETDEV_UP, idev->dev);
 }

