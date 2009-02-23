From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Why linux keeps connected routes when link goes down
Date: Mon, 23 Feb 2009 09:38:30 -0500
Message-ID: <20090223143830.GA23244@csclub.uwaterloo.ca>
References: <200902190203.41497.homecreate@list.ru> <20090218.155207.139931991.davem@davemloft.net> <20090220171912.GA7315@csclub.uwaterloo.ca> <20090220.121508.252047266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: homecreate@list.ru, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:54998 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753669AbZBWOib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 09:38:31 -0500
Content-Disposition: inline
In-Reply-To: <20090220.121508.252047266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2009 at 12:15:08PM -0800, David Miller wrote:
> This is not necessarily true.
> 
> The subnet might be reachable by one of the other interfaces.
> Just the same as someone might be able to reach the down
> interface's IP address via another one of our interfaces.

If you assign IPs for the same subnet to two different interfaces in
linux, the results are not particularly useful.  The route contains
the interface associated with the creation of the route, and since
it doesn't go away even if you had the same route for two interfaecs,
it will never use the second one.

> The route is tied to the IP address, and the route is therefore
> created and destroyed alongside the IP address.

That's how it works now.  It wasn't how it worked in linux a long
time ago.  Long ago you had to create the route yourself in userspace
(which was actually to some extent better than the current setup).
The current method is simpler to understand for your typical user though.

> As long as the IP address is active and associated with the
> system, so is the route.

Exactly, and that's the problem when trying to be a router.  You still
want to be able to reach the system through any of the IPs assigned
to it, and you would prefer to still be able to reach any networks
through alternate routes if they exist.  The way linux, BSD and other
unix systems behave is counter productive to routing, and hence not the
way real router OSs work.

Fortunately patching some sense into the linux kernel isn't very hard.

-- 
Len Sorensen
