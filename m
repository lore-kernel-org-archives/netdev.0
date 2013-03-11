From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Fwd: [PATCH] phydev: Add sysctl variable for polling interval
 of phy
Date: Mon, 11 Mar 2013 20:39:35 +0000
Message-ID: <1363034375.2608.83.camel@bwh-desktop.uk.solarflarecom.com>
References: <2566257.7001362959040495.JavaMail.weblogic@epv6ml10>
	 <513DB5C9.9020807@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <eunb.song@samsung.com>, <netdev@vger.kernel.org>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6991 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017Ab3CKUji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 16:39:38 -0400
In-Reply-To: <513DB5C9.9020807@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-11 at 11:45 +0100, Florian Fainelli wrote:
> Hello,
> 
> On 03/11/2013 12:44 AM, EUNBONG SONG wrote:
> >
> >  From d55a22be52e5a768409aa0999d6636cdfc369676 Mon Sep 17 00:00:00 2001
> > From: eunbonsong
> > Date: Sun, 10 Mar 2013 04:57:39 -0700
> > Subject: [PATCH] phydev: Add sysctl variable for polling interval of phy state
> >
> > This adds a dev.phy.phy_poll_interval sysctl variable. This value is represented in milliseconds.
> > And phy_state_machine() is scheduled as this variable.
> > I think HZ is enough for PC. But sometimes especially in network devices
> > such as switches,routers, needs more granularity for detecting phy state change.
> 
> This patch should be submitted according to the rules described in: 
> https://www.kernel.org/doc/Documentation/SubmittingPatches
> 
> Besides that, I do not think that a system-wide knob here is 
> appropriate, you may rather introduce a new ethtool ioctl() to change 
> the PHY device polling interval on a per-PHY device basis.

That sounds like the right place - if it's really necessary to make this
configurable.

> Having said that don't your devices support a dedicated PHY interrupt 
> line? This would definitively be the way to get better latency with 
> respect to PHY events reported back to the host.
[...]

It's nice to have working link interrupts, but they're apparently easy
to get wrong and it just doesn't hurt that much to poll.  They never
worked properly on SFC4000 boards, and polling once a second was good
enough in practice.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
