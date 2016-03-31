From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Best way to reduce system call overhead for tun device I/O?
Date: Thu, 31 Mar 2016 16:39:32 -0700
Message-ID: <20160331163932.3617e7cd@xeon-e3>
References: <20160329224043.GY3784@sliepen.org>
	<CALx6S37xsTeDyMHOEiGzjpbR_5zFw6XSDEgPkZqpUzEa9WDStg@mail.gmail.com>
	<20160331.172050.1423948167839485574.davem@davemloft.net>
	<20160331222857.GH3771@sliepen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tom@herbertland.com,
	netdev@vger.kernel.org
To: Guus Sliepen <guus@tinc-vpn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35938 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757627AbcCaXjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:39:18 -0400
Received: by mail-pa0-f45.google.com with SMTP id tt10so76484275pab.3
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 16:39:17 -0700 (PDT)
In-Reply-To: <20160331222857.GH3771@sliepen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 1 Apr 2016 00:28:57 +0200
Guus Sliepen <guus@tinc-vpn.org> wrote:

> On Thu, Mar 31, 2016 at 05:20:50PM -0400, David Miller wrote:
> 
> > >> I'm trying to reduce system call overhead when reading/writing to/from a
> > >> tun device in userspace. [...] What would be the right way to do this?
> > >>
> > > Personally I think tun could benefit greatly if it were implemented as
> > > a socket instead of character interface. One thing that could be much
> > > better is sending/receiving of meta data attached to skbuf. For
> > > instance GSO data could be in ancillary data in a socket instead of
> > > inline with packet data as tun seems to be doing now.
> > 
> > Agreed.
> 
> Ok. So how should the userspace API work? Creating an AF_PACKET socket
> and then using a tun ioctl to create a tun interface and bind it to the
> socket?
> 
> int fd = socket(AF_PACKET, ...)
> struct ifreq ifr = {...};
> ioctl(fd, TUNSETIFF, &ifr);
> 

Rather than bodge AF_PACKET onto TUN, why not just create a new device type
and control it from something modern like netlink.
