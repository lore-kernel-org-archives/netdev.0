From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 1/2] IPV4: remove addresses and routes when carrier is
 lost
Date: Tue, 3 Jun 2008 08:57:07 -0700
Message-ID: <20080603085707.51fdabbb@speedy>
References: <20080602165249.52a467dc@extreme>
	<20080603150524.GA16165@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59438 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751688AbYFCP5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 11:57:34 -0400
In-Reply-To: <20080603150524.GA16165@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Jun 2008 11:05:24 -0400
lsorense@csclub.uwaterloo.ca (Lennart Sorensen) wrote:

> On Mon, Jun 02, 2008 at 04:52:49PM -0700, Stephen Hemminger wrote:
> > This patch adds a new configuration sysctl that causes link loss to clear
> > FIB state in the same way as admin down. This allows for routing daemons
> > like Quagga which have option to remove routes when carrier is lost.
> > 
> > This has been a long standing problem with Quagga on Linux with complaints
> > on the developers list going back to 2004. Fixing it properly, so the routing 
> > daemon manages the RIB, and the kernel manages the FIB, requires changes to
> > both parts.
> 
> Does this cover only the local route for the interface, or all routes
> assigned staticly to the interface too?

The patch makes carrier down == interface down. So the same
behaviour as doing 'ip link set dev eth3 down'

> Certianly if I do ifconfig eth3 down, it removes all the routes, but
> doing ifconfig eth3 up only adds back the directly connected network
> based on the IP and netmask, but my static routes are gone which is a
> problem.

If you are using a routing daemon like quagga, it will restore your static
routes.


> I have been considering writing a user space daemon to listen on netlink
> for link up/down events to remove routes from the routing table and then
> add them back when the link is restored since I couldn't find a good way
> to make the kernel remember the static routes when the link was brought
> down.

That is pretty much what zebra portion of quagga does.
