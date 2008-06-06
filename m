From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 1/2] IPV4: remove addresses and routes when carrier is lost
Date: Fri, 6 Jun 2008 10:56:05 -0400
Message-ID: <20080606145605.GB31127@csclub.uwaterloo.ca>
References: <20080602165249.52a467dc@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:60623 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751691AbYFFO4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 10:56:08 -0400
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

There is one slight annoyance in the behaviour of this patch.

It only takes effect the first time link is lost, so if you boot with a
port without link, its addresses and routes are still added, and only
after it gains link and looses it again does it get removed.  Makes for
a somewhat inconsistent behaviour unfortunately.

Any idea how to change that?

Otherwise this looks like a very useful patch when combined with zebra
to manage static routes with link-detect (along with vyatta's updates to
zebra to make it actually obey link detect for routes).

-- 
Len Sorensen
