From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 iproute2] get_rate: detect 32bit overflows
Date: Mon, 3 Jun 2013 17:31:49 +0100
Message-ID: <1370277109.1918.21.camel@bwh-desktop.uk.level5networks.com>
References: <1370199083.24311.43.camel@edumazet-glaptop>
	 <1370209008.24311.91.camel@edumazet-glaptop>
	 <1370270231.1918.10.camel@bwh-desktop.uk.level5networks.com>
	 <1370272783.24311.148.camel@edumazet-glaptop>
	 <1370273807.1918.20.camel@bwh-desktop.uk.level5networks.com>
	 <1370274693.24311.154.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:37011 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759239Ab3FCQby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 12:31:54 -0400
In-Reply-To: <1370274693.24311.154.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 08:51 -0700, Eric Dumazet wrote:
> On Mon, 2013-06-03 at 16:36 +0100, Ben Hutchings wrote:
> 
> > Oops, I read this as being strtol() currently, not strtod().  Currently
> > '1.5gbit' will work, but this change will break that.  So I think you
> > need to keep bps as a double.
> 
> Arg
> 
> > Then here I think the check should be *rate != floor(bps), i.e. accept
> > rounding down of a non-integer number of bytes but any other change is
> > assumed to be overflow.
> 
> Thanks Ben, here is v4 then ;)
> 
> [PATCH v4] get_rate: detect 32bit overflows
> 
> Current rate limit is 34.359.738.360 bit per second, and
> unfortunately 40Gbps links are above it.
> 
> overflows in get_rate() are currently not detected, and some
> users are confused. Let's detect this and complain.
> 
> Note that some qdisc are ready to get extended range, but this will
> need additional attributes and new iproute2
> 
> With help from Ben Hutchings
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
[...]

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
