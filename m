From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: properly apply change to
 ignore_routes_on_linkdown to all interfaces
Date: Sun, 06 Mar 2016 22:38:21 -0500 (EST)
Message-ID: <20160306.223821.1949140799875890455.davem@davemloft.net>
References: <1456936986-2042-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbcCGDiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 22:38:23 -0500
In-Reply-To: <1456936986-2042-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Wed,  2 Mar 2016 11:43:06 -0500

> Any change to sysctl net.ipv4.conf.all.ignore_routes_with_linkdown does
> not result in a change to all interfaces on the system.  This means that
> any devices initialized before sysctl settings are applied on boot do
> not see a change if the sysctl setting is different than what the stack
> has as a default ('0' in this case).
> 
> This patch changes the net.ipv4.conf.all.ignore_routes_with_linkdown
> setting to match what is done for forwarding for ipv4 and for
> ignore_routes_with_linkdown for ipv6.  The current behavior was not
> intentional and had I recognized this corner-case before posting I would
> have done this with the first series.
> 
> Fixes: 0eeb075fad73 ("net: ipv4 sysctl option to ignore routes when nexthop link is down")
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> ---
> Generic infrastructure could be added to do this for all values, but I'm
> hesitant to do this since historically users are probably depending on
> the exiting behavior (whether intentional or not) for the more widely
> used sysctls.

"Properly" is a matter of interpretation.

Traditionally the way ipv4 works for most sysctls is that we pick up
the default and all values at the time the device get's it's ipv4
private attached (first ipv4 address configured, etc.)

So it's a bit too late now to change this behavior.

Yes, that's even if ipv6 behaves differently, and that's even if some
other ipv4 sysctls behave differently too.

I'm not applying this, sorry.
