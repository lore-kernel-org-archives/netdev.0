From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] net: ipv6 sysctl option to ignore
 routes when nexthop link is down
Date: Thu, 13 Aug 2015 21:27:48 -0700 (PDT)
Message-ID: <20150813.212748.1239473674146629403.davem@davemloft.net>
References: <1439476741-952-1-git-send-email-gospo@cumulusnetworks.com>
	<1439476741-952-2-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbbHNE1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 00:27:48 -0400
In-Reply-To: <1439476741-952-2-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Thu, 13 Aug 2015 10:39:01 -0400

> Like the ipv4 patch with a similar title, this adds a sysctl to allow
> the user to change routing behavior based on whether or not the
> interface associated with the nexthop was an up or down link.  The
> default setting preserves the current behavior, but anyone that enables
> it will notice that nexthops on down interfaces will no longer be
> selected:
> 
> net.ipv6.conf.all.ignore_routes_with_linkdown = 0
> net.ipv6.conf.default.ignore_routes_with_linkdown = 0
> net.ipv6.conf.lo.ignore_routes_with_linkdown = 0
> ...
> 
> When the above sysctls are set, not only will link status be reported to
> userspace, but an indication that a nexthop is dead and will not be used
> is also reported.
> 
> 1000::/8 via 7000::2 dev p7p1  metric 1024 dead linkdown  pref medium
> 1000::/8 via 8000::2 dev p8p1  metric 1024  pref medium
> 7000::/8 dev p7p1  proto kernel  metric 256 dead linkdown  pref medium
> 8000::/8 dev p8p1  proto kernel  metric 256  pref medium
> 9000::/8 via 8000::2 dev p8p1  metric 2048  pref medium
> 9000::/8 via 7000::2 dev p7p1  metric 1024 dead linkdown  pref medium
> fe80::/64 dev p7p1  proto kernel  metric 256 dead linkdown  pref medium
> fe80::/64 dev p8p1  proto kernel  metric 256  pref medium
> 
> This also adds devconf support and notification when sysctl values
> change.
> 
> v2: drop use of rt6i_nhflags since it is not needed right now
> 
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>

Applied.
