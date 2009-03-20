From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/3] dsa: add switch chip cascading support
Date: Fri, 20 Mar 2009 22:23:11 +0100
Message-ID: <20090320212310.GZ4738@xi.wantstofly.org>
References: <20090320195209.GW4738@xi.wantstofly.org> <1237583778.3217.4.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Gary Thomas <gary@mlbassoc.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:41303 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbZCTVXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 17:23:13 -0400
Content-Disposition: inline
In-Reply-To: <1237583778.3217.4.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 09:16:18PM +0000, Ben Hutchings wrote:

> > For the example topology above, the dsa platform data would look
> > something like this:
> > 
> > 	static struct dsa_chip_data sw[2] = {
> > 		{
> > 			.mii_bus	= &foo,
> > 			.sw_addr	= 1,
> > 			.port_names[0]	= "p1",
> > 			.port_names[1]	= "p2",
> > 			.port_names[2]	= "p3",
> > 			.port_names[3]	= "p4",
> > 			.port_names[4]	= "p5",
> > 			.port_names[5]	= "p6",
> > 			.port_names[6]	= "p7",
> > 			.port_names[7]	= "p8",
> > 			.port_names[9]	= "dsa",
> > 			.port_names[10]	= "cpu",
> > 			.rtable		= (s8 []){ -1, 9, },
> [...]
> 
> Is there supposed to be a gap in the numbering here?  The diagram above
> seemed to number the ports 1-10 but I'm guessing the internal numbering
> of those would be 0-9.

Yeah, that was intended.  On this particular chip model, ports 0-7
are RJ45 ports, 8-9 are SERDES ports, and 10 can either be SERDES or
(R)GMII -- so 10 is a natural choice for the cpu port, 8 and 9 can
be used as interconnect ports to other switches, and 0-7 are used
to connect end-stations to.  If there was another switch chip, we
could connect it to port 8 of switch #0.
