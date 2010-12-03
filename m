From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Fri, 03 Dec 2010 13:27:19 +0000
Message-ID: <1291382839.8025.40.camel@localhost>
References: <20101203103447.GA29714@hostway.ca>
	 <1291375743.2897.141.camel@edumazet-laptop>
	 <20101203123617.GA6993@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Simon Kirby <sim@hostway.ca>, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50875 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab0LCN10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 08:27:26 -0500
In-Reply-To: <20101203123617.GA6993@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-03 at 21:36 +0900, Simon Horman wrote:
> On Fri, Dec 03, 2010 at 12:29:03PM +0100, Eric Dumazet wrote:
[...]
> > I believe Simon Horman has some patches for GRO and LVS.
> > 
> > Please send the results of "ethtool -k eth0" on all your nics / vlans ?
> > 
> > For TSO, I am not sure why and where it could matter...
> 
> There is a patch to teach LVS how to cope with GRO in nf-next-2.6
> and I expect it to be included in 2.6.38. The patch is "ipvs: allow
> transmit of GRO aggregated skbs" and perhaps it should be considered
> for 2.6.37 and stable. In general the work around is to disable GRO.
>
> The patch does not resolve the incompatibility of LVS with LRO.
> The work around there is to disable LRO. I'm not entirely sure
> how to teach LVS to disable LRO automatically, or if its desirable.
[...]

I think it is desirable, and we already do it for bridging and
forwarding - we call dev_disable_lro() whenever a device is added to a
bridge or has forwarding enabled.  For IPVS it looks like you would have
to resolve the server IP address to a device first.  Though if the
administrator assigns the server address to a different interface later
then the failure mode will be very hard to understand.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

