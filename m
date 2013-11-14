From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next 2/2] udp: add sk opt to allow sending pkt with src 0.0.0.0
Date: Thu, 14 Nov 2013 15:31:54 +0100
Message-ID: <20131114143154.GD26901@order.stressinduktion.org>
References: <20131105205744.GK8832@order.stressinduktion.org> <1383958474-6255-1-git-send-email-nicolas.dichtel@6wind.com> <1383958474-6255-2-git-send-email-nicolas.dichtel@6wind.com> <20131111.001803.110603937316567461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, jiri@resnulli.us, vyasevich@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, thaller@redhat.com, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42882 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503Ab3KNObz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 09:31:55 -0500
Content-Disposition: inline
In-Reply-To: <20131111.001803.110603937316567461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 12:18:03AM -0500, David Miller wrote:
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Sat,  9 Nov 2013 01:54:34 +0100
> 
> > This feature allows to a send packets with address source set to 0.0.0.0 even if
> > an ip address is available on another interface.
> > 
> > It's useful for DHCP client, to allow them to use UDP sockets and be compliant
> > with the RFC2131, Section 4.1:
> > 
> > 4.1 Constructing and sending DHCP messages
> > ...
> >    DHCP messages broadcast by a client prior to that client obtaining
> >    its IP address must have the source address field in the IP header
> >    set to 0.
> > 
> > Based on a previous work from
> > Guillaume Gaudonville <guillaume.gaudonville@6wind.com>.
> > 
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> This requirement of the RFC is inconsistent with a host based
> addressing model, that which Linux employs, it assumes an interface
> based one.
> 
> The wording here is also very ambiguous.
> 
> This RFC fails to even remotely consider what the right behavior
> should be in a host based addressing environment at all, and anyone
> reading this RFC should just accept that.
> 
> Furthermore, the fact that you're implementing _addressing_ policy in
> the UDP code makes this change even more unreasonable.

I agree on this and will check how other operating systems which only
use sockets do deal with that.

Do you have an idea how to deal with the rp_filter issue if no ip address is
set? Should we relax it in such cases?

Greetings,

  Hannes
