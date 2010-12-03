From: Simon Horman <horms@verge.net.au>
Subject: Re: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Fri, 3 Dec 2010 22:39:53 +0900
Message-ID: <20101203133953.GA28524@verge.net.au>
References: <20101203103447.GA29714@hostway.ca>
 <1291375743.2897.141.camel@edumazet-laptop>
 <20101203123617.GA6993@verge.net.au>
 <1291382839.8025.40.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Simon Kirby <sim@hostway.ca>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51700 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756250Ab0LCNj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 08:39:56 -0500
Content-Disposition: inline
In-Reply-To: <1291382839.8025.40.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 03, 2010 at 01:27:19PM +0000, Ben Hutchings wrote:
> On Fri, 2010-12-03 at 21:36 +0900, Simon Horman wrote:
> > On Fri, Dec 03, 2010 at 12:29:03PM +0100, Eric Dumazet wrote:
> [...]
> > > I believe Simon Horman has some patches for GRO and LVS.
> > > 
> > > Please send the results of "ethtool -k eth0" on all your nics / vlans ?
> > > 
> > > For TSO, I am not sure why and where it could matter...
> > 
> > There is a patch to teach LVS how to cope with GRO in nf-next-2.6
> > and I expect it to be included in 2.6.38. The patch is "ipvs: allow
> > transmit of GRO aggregated skbs" and perhaps it should be considered
> > for 2.6.37 and stable. In general the work around is to disable GRO.
> >
> > The patch does not resolve the incompatibility of LVS with LRO.
> > The work around there is to disable LRO. I'm not entirely sure
> > how to teach LVS to disable LRO automatically, or if its desirable.
> [...]
> 
> I think it is desirable, and we already do it for bridging and
> forwarding - we call dev_disable_lro() whenever a device is added to a
> bridge or has forwarding enabled.  For IPVS it looks like you would have
> to resolve the server IP address to a device first.  Though if the
> administrator assigns the server address to a different interface later
> then the failure mode will be very hard to understand.

Thanks, I'll try and make it so.

