From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/3] net_tstamp: Add SIOCGHWTSTAMP ioctl
Date: Thu, 14 Nov 2013 01:50:51 -0500 (EST)
Message-ID: <20131114.015051.400187844893744601.davem@davemloft.net>
References: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47963 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916Ab3KNGu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 01:50:56 -0500
In-Reply-To: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 14 Nov 2013 02:37:15 +0000

> SIOCSHWTSTAMP returns the real configuration to the application
> using it, but there is currently no way for any other
> application to find out the configuration non-destructively.
> 
> This series adds a new ioctl with the obvious name which just reads the
> configuration, and an example implementation for the sfc driver.
> 
> This information could alternately be added to struct ethtool_ts_info
> returned by the ethtool ETHTOOL_GET_TS_INFO command, although that
> wouldn't be very symmetric.  There would also be a problem of how to
> indicate whether this extra information is present, given that all
> fields of hwtstamp_config can validly be 0.

No objections to the new ioctl, but you absolutely need to implement
the appropriate compat ioctl handler in net/socket.c just as we have
one for the existing SIOCSHWTSTAMP.

Thanks.
