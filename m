From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: remove netif_running() check from
 myri10ge_poll()
Date: Thu, 20 Dec 2007 16:37:08 -0800 (PST)
Message-ID: <20071220.163708.08256310.davem@davemloft.net>
References: <47602AAA.8060204@myri.com>
	<20071212.110243.202840959.davem@davemloft.net>
	<20071220160518.fa65ac90.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49355
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755232AbXLUAhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 19:37:09 -0500
In-Reply-To: <20071220160518.fa65ac90.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 20 Dec 2007 16:05:18 -0800

> On Wed, 12 Dec 2007 11:02:43 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Andrew Gallatin <gallatin@myri.com>
> > Date: Wed, 12 Dec 2007 13:38:34 -0500
> > 
> > > Remove the bogus netif_running() check from myri10ge_poll().
> > > 
> > > This eliminates any chance that myri10ge_poll() can trigger
> > > an oops by calling netif_rx_complete() and returning
> > > with work_done == budget.
> > > 
> > > Signed-off-by: Andrew Gallatin <gallatin@myri.com>
> > 
> > Acked-by: David S. Miller <davem@davemloft.net>
> 
> hm, eight days old, fixes a possible oops and hasn't been merged anywhere
> yet?
> 
> I'll put it in my for-2.6.24-via-other-subsystem queue.

This actually adds a bug back into the code.

We're trying to work out how to cleanly break out of
the net_rx_action() ->poll() loop when a device is
brought down yet getting hammered with packets.

I'll try to devote some time to this over the weekend,
meanwhile just toss this patch, we know it's an issue
that all the drivers need to get audited for but we
can't fix that until the above paragraph stuff is worked
out.

Thanks.
