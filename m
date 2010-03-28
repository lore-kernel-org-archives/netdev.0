From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] GTSM for IPv6
Date: Sun, 28 Mar 2010 08:57:27 -0700
Message-ID: <20100328085727.48e089c0@nehalam>
References: <20100319095640.42c8d82d@nehalam>
	<4BA71BDC.1080609@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42948 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755337Ab0C1WzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Mar 2010 18:55:03 -0400
In-Reply-To: <4BA71BDC.1080609@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Mar 2010 16:27:24 +0900
YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> wrote:

> (2010/03/20 1:56), Stephen Hemminger wrote:
> > Also RFC doesn't explicitly address GTSM on IPV6.
> > Maybe the RFC editors think the problem will magically no longer exist
> > in IPv6 world because everyone will be using IPsec.
> 
> > ---
> >   include/linux/in6.h      |    3 +++
> >   include/linux/ipv6.h     |    3 ++-
> >   net/ipv6/ipv6_sockglue.c |   12 ++++++++++++
> >   net/ipv6/tcp_ipv6.c      |   17 ++++++++++++++---
> >   4 files changed, 31 insertions(+), 4 deletions(-)
> 
> Why don't we have code for other protocols such as
> UDP etc?  We already have similar protection in NDP,
> It seem to make sense.
> 
> And, as many other socket options (such as IPV6_UNICAST_HOPS
> etc.) do, please accept value of -1 to set the system's
> default (0 so far).
> 
>              x < -1:        return an error of EINVAL
>              x == -1:       use kernel default
>              0 <= x <= 255: use x
>              x >= 256:      return an error of EINVAL
> 
> We may also want to have sysctl for it.

The choice was made with IPv4 to follow the precedent of FreeBSD.
And it makes sense to me to have IPv6 follow what IPv4 did.

It doesn't make sense as a sysctl value since the value is associated
with a socket. It requires both sides to cooperate and the path
has to be known. The sender sets the hop count to 255 and the receiver
knows the sender is at most N hops away. The receiver then sets the
MIN_HOPCOUNT value to 255 - N.

Implementing GTSM for UDP, SCTP, DCCP is left as an exercise for
the reader. It can't be done in the IP layer since the IP layer
does not a socket and shouldn't be looking it up.
