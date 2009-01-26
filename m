From: Steve.Glendinning@smsc.com
Subject: Re: [RFC PATCH] smsc911x: protect INT_EN read-modify-write with spinlock
Date: Mon, 26 Jan 2009 09:56:55 +0000
Message-ID: <OF91A6D7F4.9B4360B2-ON8025754A.0035FFA5-8025754A.0036C687@smsc.com>
References: <20090125.174736.268120930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: ian.saturley@smsc.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1524 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750944AbZAZJ6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 04:58:43 -0500
In-Reply-To: <20090125.174736.268120930.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 26/01/2009 01:47:36:

> From: Steve Glendinning <steve.glendinning@smsc.com>
> Date: Tue, 20 Jan 2009 14:01:54 +0000
> 
> > This patch adds a new spinlock to protect read-modify-writes to the
> > INT_EN register when enabling and disabling interrupt sources.
> > 
> > I haven't actually seen any devices lock up, but I think there's a
> > possibility and I'd like to eliminate it.
> > 
> > Should I add this new spinlock, or should I extend the mac_lock
> > to also cover these sections (renaming it to simply "lock")?
> > 
> > Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> 
> If you didn't have all of these RX multicast workaround
> cases, things would be much easier.
> 
> The POLL and normal interrupt paths are already completely atomic for
> you already.  And since POLL cannot happen until open() completes
> that path would be safe too.
> 

Thanks for looking this over David.

It looks like I can do away with the need for this if I leave RXSTOP_INT
permanently enabled and use a flag in pdata to indicate whether the ISR
should do a multicast filter update.  Does this sound reasonable?

Please drop this patch.

Steve
