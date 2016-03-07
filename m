From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] ipv4: properly apply change to
 ignore_routes_on_linkdown to all interfaces
Date: Mon, 7 Mar 2016 08:21:06 -0500
Message-ID: <20160307132105.GH33942@gospo.home.greyhouse.net>
References: <1456936986-2042-1-git-send-email-gospo@cumulusnetworks.com>
 <20160306.223821.1949140799875890455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:36676 "EHLO
	mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbcCGNUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 08:20:48 -0500
Received: by mail-yw0-f180.google.com with SMTP id g3so37704018ywa.3
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 05:20:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160306.223821.1949140799875890455.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 06, 2016 at 10:38:21PM -0500, David Miller wrote:
> From: Andy Gospodarek <gospo@cumulusnetworks.com>
> Date: Wed,  2 Mar 2016 11:43:06 -0500
> 
> > Any change to sysctl net.ipv4.conf.all.ignore_routes_with_linkdown does
> > not result in a change to all interfaces on the system.  This means that
> > any devices initialized before sysctl settings are applied on boot do
> > not see a change if the sysctl setting is different than what the stack
> > has as a default ('0' in this case).
> > 
> > This patch changes the net.ipv4.conf.all.ignore_routes_with_linkdown
> > setting to match what is done for forwarding for ipv4 and for
> > ignore_routes_with_linkdown for ipv6.  The current behavior was not
> > intentional and had I recognized this corner-case before posting I would
> > have done this with the first series.
> > 
> > Fixes: 0eeb075fad73 ("net: ipv4 sysctl option to ignore routes when nexthop link is down")
> > Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> > ---
> > Generic infrastructure could be added to do this for all values, but I'm
> > hesitant to do this since historically users are probably depending on
> > the exiting behavior (whether intentional or not) for the more widely
> > used sysctls.
> 
> "Properly" is a matter of interpretation.

:-)

> Traditionally the way ipv4 works for most sysctls is that we pick up
> the default and all values at the time the device get's it's ipv4
> private attached (first ipv4 address configured, etc.)
> 
> So it's a bit too late now to change this behavior.
> 
> Yes, that's even if ipv6 behaves differently, and that's even if some
> other ipv4 sysctls behave differently too.
> 
> I'm not applying this, sorry.

I knew there was a chance you would reach this conclusion and despite
being disappointed that you don't want to allow this change I
understand.  This is essentially a behavioral change and despite the
fact that this might not be an oft-used sysctl there are some that might
rely on the current behavior.
