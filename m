From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: (Lack of) specification for RX n-tuple filtering
Date: Wed, 08 Dec 2010 17:29:24 +0000
Message-ID: <1291829364.2560.24.camel@bwh-desktop>
References: <4C48BD1A.4060409@chelsio.com>
	 <1283870637.2270.10.camel@achroite.uk.solarflarecom.com>
	 <1291825443.31064.193.camel@lb-tlvb-vladz>
	 <20101208.083921.71108761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, dm@chelsio.com,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:40390 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755130Ab0LHR31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 12:29:27 -0500
In-Reply-To: <20101208.083921.71108761.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-08 at 08:39 -0800, David Miller wrote:
> From: "Vladislav Zolotarov" <vladz@broadcom.com>
> Date: Wed, 8 Dec 2010 18:24:03 +0200
> 
> > I also agree with Dimitris: what we have here is an offload of some
> > Netfilter functionality to HW. Regardless the HW implementation (TCAM or
> > not) if it's allowed to configure more than one rule for the same
> > protocol the ordering of filtering rules is important: for instance if u
> > change the order of applying the rules in the example below the result
> > of the filtering for the traffic with both VLAN 4 and destination port
> > 3000 will be different.
> 
> It's not the same, this whole ordering thing you expect in netfilter
> land is simply not present in these hardware implementations.
> 
> The hardware does a parallel TCAM match lookup, and whatever matches
> is used.

I think the match with the lowest index wins, which is why it's possible
to specify the rule's index (location) with ETHTOOL_SRXCLSRLINS and why
Peter defined new commands without that for use with the ixgbe driver.

> Some hardware does link-level protocol lookups first, then L3/L4 later
> in the RX path right before computing the hash and selecting an RX
> queue.
>
> There really is no ordering available, so let's not pretend it can be
> used "just like" netfilter rules.
> 
> As per the difference between the various ethtool facilities, this
> just represents the fact that whats available to offload differs
> per device.  The best we can do is encapsulate commonality as best
> as we can, but each interface essentially represents what one
> major chipset provides.

I think the interfaces are actually somewhat more flexible than any of
the current implementations.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

