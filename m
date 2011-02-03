From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH] niu: fix SMP race protecting rx_rings and tx_rings
Date: Thu, 3 Feb 2011 21:18:05 -0200
Message-ID: <20110203231805.GA3710@redhat.com>
References: <1296758717-18406-1-git-send-email-fleitner@redhat.com>
 <20110203.142145.183054407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753061Ab1BCXSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 18:18:14 -0500
Content-Disposition: inline
In-Reply-To: <20110203.142145.183054407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 03, 2011 at 02:21:45PM -0800, David Miller wrote:
> From: Flavio Leitner <fleitner@redhat.com>
> Date: Thu,  3 Feb 2011 16:45:17 -0200
> 
> > It's possible to trigger a crash if one CPU is opening
> > the device while another CPU gets its statistics.
> > 
> > It happens because niu_alloc_channels() called from
> > niu_open() sets num_tx/rx_rings before allocating the
> > ring, so the other thread crashes when accessing
> > np->tx_rings[i].tx_packets at niu_get_tx_stats().
> > 
> > Signed-off-by: Flavio Leitner <fleitner@redhat.com>
>  ...
> > Compile tested only because I don't have the hardware.
> 
> I'll apply this and give it a quick test, thanks.
> 
> Can you have the person who reported this crash to you test the patch
> out at least?  That's how you learned about this problem, right,
> someone else hit the crash?
> 
> In such cases I'd really appreciate it if you got positive testing
> feedback from the reporter before posting the patch.
> 
> Longer term a better way to fix this is to RCU free the ring data
> structures, and use a quick NULL test at the top of the get stats
> implementation.

Ok, I can write a new version using RCU if you like.
I've chose rwsem because I think those operations aren't
frequent. The RCU leaves an operation to run later during
a safe context, so I thought the cost doesn't worth it.

I'm trying to get testing feedback as well, not sure yet
if it will be possible though. Anyway, I'll update here
when I heard something.

thanks!
-- 
Flavio
