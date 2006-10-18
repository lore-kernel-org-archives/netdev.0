From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Bound TSO defer time (resend)
Date: Wed, 18 Oct 2006 09:40:23 -0700
Message-ID: <20061018094023.1be31440@freekitty>
References: <Pine.LNX.4.58.0610162051170.12462@dexter.psc.edu>
	<20061016202035.6d55b96e@localhost.localdomain>
	<45345999.4000300@psc.edu>
	<200610181737.36135.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Heffner <jheffner@psc.edu>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25540 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422675AbWJRQkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 12:40:42 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200610181737.36135.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Oct 2006 17:37:36 +0200
Andi Kleen <ak@suse.de> wrote:

> On Tuesday 17 October 2006 06:18, John Heffner wrote:
> > Stephen Hemminger wrote:
> > > On Mon, 16 Oct 2006 20:53:20 -0400 (EDT)
> > > John Heffner <jheffner@psc.edu> wrote:
> > 
> > >> This patch limits the amount of time you will defer sending a TSO segment
> > >> to less than two clock ticks, or the time between two acks, whichever is
> > >> longer.
> > 
> > > 
> > > Okay, but doing any timing on clock ticks makes the behavior dependent
> > > on the value of HZ which doesn't seem desirable. Should this be based
> > > on RTT or a real-time values?
> > 
> > It would be nice to use a high res clock so you don't depend on HZ, but 
> > this is still expensive on most SMP arch's as I understand it.
> 
> You can always use xtime. It doesn't have better solution than jiffies
> though, but it gives you real time.
> 
> Drawback is that there is some work towards tickless kernels and with
> that xtime will be more expensive again. But hopefully not by that much.
> 
> -Andi

Actually the thing to use now is ktime.  It would then be compatiable
with hrtimers. But it seems a bit of overkill in this case.

-- 
Stephen Hemminger <shemminger@osdl.org>
