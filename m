From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Wed, 23 Oct 2013 14:04:34 +0200
Message-ID: <20131023120434.GA22316@secunet.com>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
 <20131022.154638.1989281525248160764.davem@davemloft.net>
 <20131023081255.GB10148@secunet.com>
 <1748378.n7GIUzQXTX@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51273 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753386Ab3JWMEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 08:04:40 -0400
Content-Disposition: inline
In-Reply-To: <1748378.n7GIUzQXTX@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 23, 2013 at 01:33:14PM +0200, Wolfgang Walter wrote:
> Am Mittwoch, 23. Oktober 2013, 10:12:55 schrieb Steffen Klassert:
> > On Tue, Oct 22, 2013 at 03:46:38PM -0400, David Miller wrote:
> > > 
> > > I think we should resolve this soon, even bumping it to 2048 or 4096
> > > and leaving it at that would be I think acceptable.
> > 
> > Yes, of course. Let's use 4096 as the default for ipv4 and ipv6.
> > I'll take care of it next week.
> > 
> 
> I don't know what this value actually means. But on 3.4.x it is much higher. 
> On a machine with 512MB ram it is 32768, on a machine with 1GB ram it is 
> 262144 and with 16GB ram it is 4194304.
> 

Before  we removed the routing cache, the gc threshold was scaled along
with the maximum routing cache size (ip_rt_max_size). With the routing
cache removal, we lost the possibility to scale with ip_rt_max_size
and we had to choose a static default. Maybe we can try to tweak the
gc threshold again with the available memory somehow later. But to fix
it now, we need to find a reasonable default value. Would a default of
4096 meet your requirements?
