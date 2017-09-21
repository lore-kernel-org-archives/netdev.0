From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 08/14] gtp: Support encpasulating over IPv6
Date: Thu, 21 Sep 2017 08:04:37 +0800
Message-ID: <20170921000437.rg2h6vyxsrbc3bel@nataraja>
References: <20170919003904.5124-9-tom@quantonium.net>
 <20170918.211952.1397675528248642600.davem@davemloft.net>
 <CALx6S36cJEU2LkbNf-d8kUHCPj78bt5Y2Bd_rdvjxJ9epOEqAQ@mail.gmail.com>
 <20170920.124511.922311380432026759.davem@davemloft.net>
 <CALx6S36zz1CFq75S5-=UK8wtuK-pxaQdWU7tVuRGhtb_Y9QkDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit Seth <rohit@quantonium.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:60999 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751640AbdIUANb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 20:13:31 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S36zz1CFq75S5-=UK8wtuK-pxaQdWU7tVuRGhtb_Y9QkDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Wed, Sep 20, 2017 at 01:40:54PM -0700, Tom Herbert wrote:
> On Wed, Sep 20, 2017 at 12:45 PM, David Miller <davem@davemloft.net> wrote:
> > There is a socket associated with the tunnel to do the encapsulation
> > and it has an address family, right?
> 
> If fd's are set from userspace for the sockets then we could derive
> the address family from them. I'll change that. Although, looking at
> now I am wondering why were passing fds into GTP instead of just
> having the kernel create the UDP port like is done for other encaps.

because the userspace process has to take care of those bits of GTP-U
that the kernel doesn't, such as responding to GTP ECHO requests with
GTP echo responses.  Only the "GTP Message type G-PDU" is handled in the
kernel, as only those frames contain user plane.  See table 1 of Section
7.1 of 3GPP TS 29.060.

If you create the socket in the kernel, how would you hand the socket to
the userspace process later on?

IMHO, it feels more natural to simply create it in userspace (like you
would do in the non-kernel-accelerated case) and then simply handle the
G-PDU messages in the kernel while doing the rest in userspace.

But if there's another method that feels more usual to the kernel
community, I'm not against any changes - but given kernel policies, we'd
have to keep userspace compatbility, right?

Regards,
	Harald
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
