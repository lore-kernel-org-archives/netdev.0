From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] bridge: allow forwarding some link local frames
Date: Wed, 05 Oct 2011 20:40:19 +0100
Message-ID: <1317843619.2802.32.camel@bwh-desktop>
References: <20111004041444.793960297@vyatta.com>
	 <20111004041509.292932641@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:57174 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933747Ab1JETkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 15:40:22 -0400
In-Reply-To: <20111004041509.292932641@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-10-03 at 21:14 -0700, Stephen Hemminger wrote:
> plain text document attachment (bridge-multicast-filter.patch)
> This is based on an earlier patch by Nick Carter with comments
> by David Lamparter but with some refinements. Thanks for their patience
> this is a confusing area with overlap of standards, user requirements,
> and compatibility with earlier releases.
> 
> It adds a new sysfs attribute 
>    /sys/class/net/brX/bridge/group_fwd_mask
> that controls forwarding of frames with address of: 01-80-C2-00-00-0X
> The default setting has no forwarding to retain compatibility.
> 
> One change from earlier releases is that forwarding of group
> addresses is not dependent on STP being enabled or disabled. This
> choice was made based on interpretation of tie 802.1 standards.
> I expect complaints will arise because of this, but better to follow
> the standard than continue acting incorrectly by default.
> 
> The filtering mask is writeable, but only values that don't forward
> known control frames are allowed. It intentionally blocks attempts
> to filter control protocols. For example: writing a 8 allows
> forwarding 802.1X PAE addresses which is the most common request.
[...]

I wonder why you don't forbid forwarding frames sent to reserved
destination addresses?  The standards seem pretty clear that this should
not be allowed.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
