From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/3] driver: net: ethernet: cpsw: implement ethtool
 get/set phy setting
Date: Fri, 8 Mar 2013 14:53:21 +0000
Message-ID: <1362754401.3248.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
	  <1362659421-11884-2-git-send-email-mugunthanvnm@ti.com>
	  <8762135on4.fsf@dell.be.48ers.dk>
	 <1362686350.2936.43.camel@bwh-desktop.uk.solarflarecom.com>
	 <513991E6.5080400@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Korsgaard <jacmet@sunsite.dk>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38042 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933035Ab3CHOx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 09:53:29 -0500
In-Reply-To: <513991E6.5080400@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-08 at 12:53 +0530, Mugunthan V N wrote:
> On 3/8/2013 1:29 AM, Ben Hutchings wrote:
> > On Thu, 2013-03-07 at 14:24 +0100, Peter Korsgaard wrote:
> >>>>>>> "M" == Mugunthan V N <mugunthanvnm@ti.com> writes:
> >>   M> This patch implements get/set of the phy settings via ethtool apis
> >>   M> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> >>   M> ---
> >>   M>  Documentation/devicetree/bindings/net/cpsw.txt |    3 +++
> >>   M>  drivers/net/ethernet/ti/cpsw.c                 |   32 ++++++++++++++++++++++++
> >>   M>  include/linux/platform_data/cpsw.h             |    1 +
> >>   M>  3 files changed, 36 insertions(+)
> >>
> >>   M> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
> >>   M> index ecfdf75..8d61300 100644
> >>   M> --- a/Documentation/devicetree/bindings/net/cpsw.txt
> >>   M> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
> >>   M> @@ -20,6 +20,7 @@ Required properties:
> >>   M>  - cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
> >>   M>  - phy_id		: Specifies slave phy id
> >>   M>  - mac-address		: Specifies slave MAC address
> >>   M> +- ethtool-active-slave	: Specifies the slave to use for ethtool command
> >>
> >> That again sounds like something Linux specific rather than a hardware
> >> property.
> > Yes, indeed.  Isn't it redundant with the phy_id?
> >
> > Ben.
> phy_id is part of slave data and will be present for both the slaves.
> so phy_id cannot be used for get/set phy setting until phy framework
> allows to change settings without going through eth interface.

Now I've looked at the examples in this file, I think I see what you're
getting at.  What confused me is that you're adding to a single list of
properties without a proper distinction of which devices they are
applied to.  It really ought to be properly divided between switch and
'slave' properties.

The 'active slave' property would also be needed for the SIOCGMIIPHY
ioctl and not just ethtool.  But it's really quite arbitrary.  Perhaps
each of them should have their own net device (as with DSA).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
