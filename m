From: Guus Sliepen <guus@tinc-vpn.org>
Subject: Re: Best way to reduce system call overhead for tun device I/O?
Date: Mon, 4 Apr 2016 16:40:19 +0200
Message-ID: <20160404144019.GN3771@sliepen.org>
References: <20160329224043.GY3784@sliepen.org>
 <CALx6S37xsTeDyMHOEiGzjpbR_5zFw6XSDEgPkZqpUzEa9WDStg@mail.gmail.com>
 <20160331.172050.1423948167839485574.davem@davemloft.net>
 <20160331222857.GH3771@sliepen.org>
 <20160331163932.3617e7cd@xeon-e3>
 <CAF=yD-LUaxsJMZiGXQdEDh-6UE11ApL89rjt=13oLK3FM1rerQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arianus.sliepen.org ([92.243.30.131]:39148 "EHLO
	arianus.sliepen.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbcDDOkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 10:40:22 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-LUaxsJMZiGXQdEDh-6UE11ApL89rjt=13oLK3FM1rerQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 03, 2016 at 07:03:09PM -0400, Willem de Bruijn wrote:

> On Thu, Mar 31, 2016 at 7:39 PM, Stephen Hemminger <stephen@networkplumber.org> wrote:
>
> > Rather than bodge AF_PACKET onto TUN, why not just create a new device type
> > and control it from something modern like netlink.

Do we really want to introduce a whole new device type? The tun device
is working perfectly fine, except for the fact that there is no way to
send/receive multiple packets in one go.

> Depending on the use-case, it may be sufficient to extend AF_PACKET
> with limited tap functionality:
> 
> - add a po->xmit mode that reinjects into the kernel receive path,
>   analogous to pktgen's M_NETIF_RECEIVE mode.
> 
> - optionally drop packets in __netif_receive_skb_core and xmit_one
>   if any of the registered packet sockets accepted the packet and has
>   a new intercept feature flag enabled.
> 
> This can be applied to a dummy device, but much more interesting
> is to interpose on the flow of a normal nic. It is clearly not a drop-in
> replacement for a tap (let alone tun) device. I have some preliminary
> code.

It's not really tinc's use case, but I did try using socket(AF_PACKET)
bound to a tun interface, just to see if sendmmsg()/recvmmsg() works
then. It does, but indeed for packets that are sent to the socket, they
need to be reinjected into the kernel receive path. So I'll be happy to
test out your preliminary code.

-- 
Met vriendelijke groet / with kind regards,
     Guus Sliepen <guus@tinc-vpn.org>
