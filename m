From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: IPv6 xfrm GSO fragmentation bug
Date: Mon, 31 Aug 2015 09:19:16 +0200
Message-ID: <20150831071916.GG25499@secunet.com>
References: <20150830082432.GA25588@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56510 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752531AbbHaHTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2015 03:19:19 -0400
Content-Disposition: inline
In-Reply-To: <20150830082432.GA25588@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 30, 2015 at 04:24:32PM +0800, Herbert Xu wrote:
> Hi Steffen:
> 
> I received a bug report regarding poor IPComp performance over
> IPv6:
> 
> 	https://bugzilla.redhat.com/show_bug.cgi?id=1257952
> 
> It appears to have been caused by
> 
> commit dd767856a36e00b631d65ebc4bb81b19915532d6
> Author: Steffen Klassert <steffen.klassert@secunet.com>
> Date:   Tue Oct 11 01:44:30 2011 +0000
> 
>     xfrm6: Don't call icmpv6_send on local error
> 
> which addded an MTU check without a GSO override.
> 
> Fixing it obviously isn't difficult, but I am wondering why I
> can't find a corresponding patch for IPv4.  Do we need that check
> to be present in xfrm6_output at all? If we do why isn't it needed
> for IPv4 as well?

As far as I remember, this was to catch local message size
errors before __xfrm6_output calls ip6_fragment which would
use icmpv6_send for the error notification. IPv4 does not do
fragmentation in the xfrm4_output functions, so this mtu
check was not needed there.

I think just adding the gso checks should be fine.
