From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Wed, 6 Nov 2013 13:03:39 +0100
Message-ID: <20131106120339.GA8144@order.stressinduktion.org>
References: <20131028.204306.2213130677400093266.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com> <20131029124010.GA15762@order.stressinduktion.org> <52792499.3030201@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B73E2@saturn3.aculab.com> <20131105211158.GL8832@order.stressinduktion.org> <AE90C24D6B3A694183C094C60CF0A2F6026B73E3@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>,
	jiri@resnulli.us, vyasevich@gmail.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, thaller@redhat.com, stephen@networkplumber.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53055 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756335Ab3KFMDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 07:03:40 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73E3@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 09:23:05AM -0000, David Laight wrote:
> > By the way:
> > Although dhclient uses an AF_PACKET socket, it never does request
> > additional multicast addresses or promisc mode. So the only overhead is
> > that we have to run the socket filter on each incoming packet.
> 
> Just creating the AF_PACKET socket requires that every receive
> frame be duplicated.
> On Linux this is a reference counted but the cost is still non-zero.
> On some other OS (I first saw this with VxWorks) it is a full data copy.

Yes, I saw that, so my guess was that running the filter on every incoming UDP
packet would be the highes cost factor (it still does get filtered by protocol
number early in the stack).
