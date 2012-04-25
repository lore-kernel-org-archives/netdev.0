From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dl2k: Tighten ioctl permissions
Date: Wed, 25 Apr 2012 18:29:54 -0400 (EDT)
Message-ID: <20120425.182954.804210541527871356.davem@davemloft.net>
References: <4F985197.1060607@suse.com>
	<1335392802.2602.33.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffm@suse.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932110Ab2DYWaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 18:30:00 -0400
In-Reply-To: <1335392802.2602.33.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 25 Apr 2012 23:26:42 +0100

> On Wed, 2012-04-25 at 15:33 -0400, Jeff Mahoney wrote:
>> dl2k's rio_ioctl function defines several ioctls that involve
>>  operations that should be denied to regular users.
>> 
>>  SIOCDEVPRIVATE + 2 is a renumbered SIOCSMIIREG.
> 
> There was an early convention that SIOCDEVPRIVATE + {0,1,2} were MDIO
> operations.  (This was a bad idea, because you can't safely send them to
> an arbitrary driver... not that that stopped people doing it.  Now it's
> neither safe to send them from userland, nor to implement any other
> semantics for these ioctl numbers in a driver.)
> 
> Please fix the numbering instead; it will make standard MII/MDIO
> utilities work and the capability check (in dev_ioctl()) comes for free.
> 
>>  SIOCDEVPRIVATE + 5 calls netif_stop_queue.
>>  SIOCDEVPRIVATE + 6 calls netif_wake_queue.
> [...]
> 
> And SIOCDEVPRIVATE + {7,8} spam the kernel log, so they should perhaps
> be considered privileged too.

And I would also say that the netif_{stop,wake}_queue ones should just
be deleted.  There is no sane way, even as a debugging facility, we
can let useland trigger these conditions.

And if we could, it belongs in a generic facility no private ioctls
which are heavily discouraged anyways.

I seriously would suggest ditching all of these private ioctls from
the dl2k driver, I bet no binary in the world out there even exists
which handles these strange renumbered MII operations.
