From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 1/2] IPV4: remove addresses and routes when carrier is lost
Date: Tue, 3 Jun 2008 11:05:24 -0400
Message-ID: <20080603150524.GA16165@csclub.uwaterloo.ca>
References: <20080602165249.52a467dc@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:54084 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750923AbYFCPFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 11:05:25 -0400
Content-Disposition: inline
In-Reply-To: <20080602165249.52a467dc@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 02, 2008 at 04:52:49PM -0700, Stephen Hemminger wrote:
> This patch adds a new configuration sysctl that causes link loss to clear
> FIB state in the same way as admin down. This allows for routing daemons
> like Quagga which have option to remove routes when carrier is lost.
> 
> This has been a long standing problem with Quagga on Linux with complaints
> on the developers list going back to 2004. Fixing it properly, so the routing 
> daemon manages the RIB, and the kernel manages the FIB, requires changes to
> both parts.

Does this cover only the local route for the interface, or all routes
assigned staticly to the interface too?

Certianly if I do ifconfig eth3 down, it removes all the routes, but
doing ifconfig eth3 up only adds back the directly connected network
based on the IP and netmask, but my static routes are gone which is a
problem.

I have been considering writing a user space daemon to listen on netlink
for link up/down events to remove routes from the routing table and then
add them back when the link is restored since I couldn't find a good way
to make the kernel remember the static routes when the link was brought
down.

-- 
Len Sorensen
