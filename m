From: Daniel Walker <dwalker@mvista.com>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 03 Aug 2006 17:03:05 -0700
Message-ID: <1154649785.16126.3.camel@dwalker1.mvista.com>
References: <20060803201741.GA7894@thunk.org>
	 <20060803.144845.66061203.davem@davemloft.net>
	 <20060803235326.GC7894@thunk.org>
	 <20060803.165654.45876296.davem@davemloft.net>
Reply-To: dwalker@mvista.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tytso@mit.edu, mchan@broadcom.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:11382 "EHLO
	gateway-1237.mvista.com") by vger.kernel.org with ESMTP
	id S1030238AbWHDADH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 20:03:07 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060803.165654.45876296.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-03 at 16:56 -0700, David Miller wrote:
> From: Theodore Tso <tytso@mit.edu>
> Date: Thu, 3 Aug 2006 19:53:26 -0400
> 
> > Any suggestions on how I could figure out what was really going on and
> > what would be a better fix would be greatly appreciated.
> 
> As Michael explained, it's the ASF heartbeat sent by tg3_timer() that
> must be delivered to the chip within certain timing constraints.
> 
> If you had any watchdog devices on this machine, they would likely
> trigger too and reset your machine :)

That's not broken behavior in RT .. That's just plain old task
priorities. Some high priority task (SCHED_FIFO prio 99) is sucking up a
lot of the CPU. But that's 100% legal in SCHED_FIFO.

Daniel

