From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [stable] [RFC] ipv6: don't flush routes when setting loopback
 down
Date: Sun, 23 Jan 2011 21:34:44 +1100
Message-ID: <20110123213444.70d0b0f1@s6510>
References: <20110122.145438.193725532.davem@davemloft.net>
	<901400353.32377.1295757672292.JavaMail.root@tahiti.vyatta.com>
	<20110122.214254.226765382.davem@davemloft.net>
	<20110123192416.73cd7521@s6510>
	<20110123192624.5cfe33d0@s6510>
	<20110123091531.GQ12837@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	stable@kernel.org, stephen.hemminger@vyatta.com,
	ebiederm@xmission.com, brian.haley@hp.com, lorenzo@google.com,
	David Miller <davem@davemloft.net>, maheshkelkar@gmail.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54749 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379Ab1AWKex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jan 2011 05:34:53 -0500
In-Reply-To: <20110123091531.GQ12837@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think this fixes the issue with disable_ipv6

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

