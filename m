From: Guus Sliepen <guus@tinc-vpn.org>
Subject: Re: Best way to reduce system call overhead for tun device I/O?
Date: Fri, 1 Apr 2016 00:28:57 +0200
Message-ID: <20160331222857.GH3771@sliepen.org>
References: <20160329224043.GY3784@sliepen.org>
 <CALx6S37xsTeDyMHOEiGzjpbR_5zFw6XSDEgPkZqpUzEa9WDStg@mail.gmail.com>
 <20160331.172050.1423948167839485574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arianus.sliepen.org ([92.243.30.131]:37685 "EHLO
	arianus.sliepen.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757369AbcCaW3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 18:29:00 -0400
Content-Disposition: inline
In-Reply-To: <20160331.172050.1423948167839485574.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2016 at 05:20:50PM -0400, David Miller wrote:

> >> I'm trying to reduce system call overhead when reading/writing to/from a
> >> tun device in userspace. [...] What would be the right way to do this?
> >>
> > Personally I think tun could benefit greatly if it were implemented as
> > a socket instead of character interface. One thing that could be much
> > better is sending/receiving of meta data attached to skbuf. For
> > instance GSO data could be in ancillary data in a socket instead of
> > inline with packet data as tun seems to be doing now.
> 
> Agreed.

Ok. So how should the userspace API work? Creating an AF_PACKET socket
and then using a tun ioctl to create a tun interface and bind it to the
socket?

int fd = socket(AF_PACKET, ...)
struct ifreq ifr = {...};
ioctl(fd, TUNSETIFF, &ifr);

-- 
Met vriendelijke groet / with kind regards,
     Guus Sliepen <guus@tinc-vpn.org>
