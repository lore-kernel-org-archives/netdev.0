From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH ipsec] xfrm: use the right dev to fill xdst
Date: Mon, 8 Apr 2013 13:42:29 +0200
Message-ID: <20130408114229.GX21448@secunet.com>
References: <1365088362-4318-1-git-send-email-nicolas.dichtel@6wind.com>
 <20130405094629.GV21448@secunet.com>
 <CAEnQRZDUjaL56AggThN50sYJpA8diQdQ85D4xCqpwtv8PbR7mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:32841 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757835Ab3DHLmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 07:42:37 -0400
Content-Disposition: inline
In-Reply-To: <CAEnQRZDUjaL56AggThN50sYJpA8diQdQ85D4xCqpwtv8PbR7mg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 05, 2013 at 03:59:59PM +0300, Daniel Baluta wrote:
> On Fri, Apr 5, 2013 at 12:46 PM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > On Thu, Apr 04, 2013 at 05:12:42PM +0200, Nicolas Dichtel wrote:
> >> Commit bc8e4b954e46 (xfrm6: ensure to use the same dev when building a bundle)
> >> broke IPsec for IPv4 over IPv6 tunnels (because dev points to an IPv4 only
> >> interface, hence in6_dev_get(dev) returns NULL.
> >
> > Can you give some informations on how to reproduce this? I'm running
> > interfamily tunnels on our testing environment and it seems to
> > work fine.
> 
> I can hit this in our setup while using some internal custom simulated
> interfaces.
> 
> Anyhow, this should be reproducible with a classic IPv6 IPsec over
> IPv4 test.  Please make sure
> that the IPv4 interface doesn't have an IPv6 address set up.
> 
> Quoting from commit bc8e4b954e46 (xfrm6: ensure to use the same dev
> when building a bundle):
> 
> -       xdst->u.rt6.rt6i_idev = in6_dev_get(rt->u.dst.dev);
> +       xdst->u.rt6.rt6i_idev = in6_dev_get(dev);
> 
> dev points to IPv4 endpoint and if it doesn't have an IPv6 address
> associated then
> in6_dev_get(dev) will return NULL.

I have ipv6 compiled into the kernel. So when I set up a netdevice, a
struct inet6_dev is allocated and associated. Therefore I have always
a valid pointer, even if I disable ipv6 for that device. That's probaply
why I can't reproduce it. I'll change my configuration and try again.
