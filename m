From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 3/8 (V2)] stmmac: add the initial tx coalesce
 schema
Date: Fri, 14 Sep 2012 00:11:15 +0100
Message-ID: <1347577875.13258.70.camel@deadeye.wl.decadent.org.uk>
References: <1347568971.13258.19.camel@deadeye.wl.decadent.org.uk>
	 <20120913.164645.1268091771093604148.davem@davemloft.net>
	 <1347570650.13258.40.camel@deadeye.wl.decadent.org.uk>
	 <20120913.173727.314155374058895289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50995 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752889Ab2IMXLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 19:11:19 -0400
In-Reply-To: <20120913.173727.314155374058895289.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-13 at 17:37 -0400, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Thu, 13 Sep 2012 22:10:50 +0100
> 
> > On Thu, 2012-09-13 at 16:46 -0400, David Miller wrote:
> >> From: Ben Hutchings <bhutchings@solarflare.com>
> >> Date: Thu, 13 Sep 2012 21:42:51 +0100
> >> 
> >> Well written NAPI drivers never need to disable hardware interrupts
> >> in their ->poll() method and it's callers, neither should you.
> > 
> > Perhaps you should get round to reviewing netpoll, because it does
> > exactly this.
> 
> Then I don't understand the point you're trying to make.
> 
> Hardware interrupt disabling has absolutely no place in the
> NAPI polling fast paths.
> 
> If NAPI drivers can't be implemented without hardware interrupt
> toggling in ->poll(), we've failed.

Right.

The problem being that NAPI poll functions *are* sometimes called in
hardware interrupt context.  Thus, any spinlock that may be taken by a
NAPI handler, may well need to be taken with spinlock_irq or
spinlock_irqsave elsewhere.  (This is horrible and I think it's well
past time that we ripped the NAPI polling out of netpoll.)

I think you're right that stmmac_tx() (completion handler?) doesn't need
to disable hardware interrupts, but sadly stmmac_xmit() does right now
unless Giuseppe can work out how to make their interaction lockless.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
