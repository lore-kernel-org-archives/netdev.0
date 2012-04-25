From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] dl2k: Tighten ioctl permissions
Date: Wed, 25 Apr 2012 23:26:42 +0100
Message-ID: <1335392802.2602.33.camel@bwh-desktop.uk.solarflarecom.com>
References: <4F985197.1060607@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Jeff Mahoney <jeffm@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:44837 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759345Ab2DYW0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 18:26:49 -0400
In-Reply-To: <4F985197.1060607@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-25 at 15:33 -0400, Jeff Mahoney wrote:
> dl2k's rio_ioctl function defines several ioctls that involve
>  operations that should be denied to regular users.
> 
>  SIOCDEVPRIVATE + 2 is a renumbered SIOCSMIIREG.

There was an early convention that SIOCDEVPRIVATE + {0,1,2} were MDIO
operations.  (This was a bad idea, because you can't safely send them to
an arbitrary driver... not that that stopped people doing it.  Now it's
neither safe to send them from userland, nor to implement any other
semantics for these ioctl numbers in a driver.)

Please fix the numbering instead; it will make standard MII/MDIO
utilities work and the capability check (in dev_ioctl()) comes for free.

>  SIOCDEVPRIVATE + 5 calls netif_stop_queue.
>  SIOCDEVPRIVATE + 6 calls netif_wake_queue.
[...]

And SIOCDEVPRIVATE + {7,8} spam the kernel log, so they should perhaps
be considered privileged too.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
