From: bert hubert <bert.hubert@netherlabs.nl>
Subject: IPv6 routing table max_size badly dimensioned compared to IPv4
Date: Thu, 27 Feb 2014 20:24:03 +0100
Message-ID: <20140227192403.GA13472@xs.powerdns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xs.powerdns.com ([82.94.213.34]:52369 "EHLO xs.powerdns.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750765AbaB0Ta0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 14:30:26 -0500
Received: from ahu by xs.powerdns.com with local (Exim 4.71)
	(envelope-from <ahu@xs.powerdns.com>)
	id 1WJ6Yt-00044X-GX
	for netdev@vger.kernel.org; Thu, 27 Feb 2014 20:24:03 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everybody,

Today, a PowerDNS (open source dns, www.powerdns.com) deployment ran into
trouble with large amounts of IPv6 users.  It appears a large telco 'flicked
the switch'.  We had around 8000 DNS queries/s over IPv6, and everything
slowed to a crawl.  100% CPU utilization, most of it in the kernel. The same
amount of queries over IPv4 causes no problems.

Note, this system is not functioning as a router or anything. It is just
serving IPv6 DNS to a reasonable number of clients.

Thanks to diligent debugging and rapid help from friends over at SUSE, who
suggested setting net.ipv6.route.max_size to a higher than default value,
all problems were quickly resolved (thanks!).

>From a quick reading of ip6_dst_gc, it is obvious that exceeding the
max_size of the IPv6 routing table quickly becomes painful, causing non-stop
gc scans.

net.ipv6.route.max_size defaults to 4096. The equivalent setting for IPv4
defaults to 'millions' or is even dynamically sizing in modern kernels.

Now I know distributions can set this sysctl at will, but it appears that
many of them don't. It does appear odd that we still assume at a kernel
level that IPv6 is 'rare', a thousand times more rare than IPv4.

If people think this is a good idea, I could try to lift some of the other
'autosizing' code out there to get the IPv6 max_size limit raised on
non-contrained hardware. 

Please let me know!

-- 
PowerDNS Website: http://www.powerdns.com/
Contact us by phone on +31-15-7850372
