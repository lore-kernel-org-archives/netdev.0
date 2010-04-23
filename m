From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e100: Fix the TX workqueue race
Date: Fri, 23 Apr 2010 16:31:27 -0700 (PDT)
Message-ID: <20100423.163127.62645049.davem@davemloft.net>
References: <20100423143356.7092.45260.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: alan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45973
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755449Ab0DWXbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 19:31:23 -0400
In-Reply-To: <20100423143356.7092.45260.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>
Date: Fri, 23 Apr 2010 15:34:43 +0100

> I'd assumed someone would have picked up on this and fixed it using rtnl_lock
> as was suggested but it seems to have fallen through the cracks ?
> 
> Anyway this is I assume what was meant ?

I hope this doesn't deadlock with linkwatch, as that's generally
a problem we hit with trying to take RTNL from workqueues in
the networking.

Linkwatch takes the RTNL lock, and then can make calls into the driver
in it's main work loop.

But since you don't hold any driver locks here (you can't as if we did
we couldn't take the RTNL lock here at all) so it should be OK.

I'll apply this to net-2.6, thanks Alan.
