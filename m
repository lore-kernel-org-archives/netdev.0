From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] atm: clip timer race
Date: Thu, 13 Apr 2006 10:26:30 -0700
Message-ID: <20060413102630.7748f7b3@localhost.localdomain>
References: <20060412105545.3b089dd8@localhost.localdomain>
	<E1FTjlM-00050V-00@gondolin.me.apana.org.au>
	<20060412124533.14e0c4ff@localhost.localdomain>
	<20060412200015.GA19878@gondor.apana.org.au>
	<20060412131527.71f42d58@localhost.localdomain>
	<20060412202551.GA20085@gondor.apana.org.au>
	<20060412145254.4dd21be6@localhost.localdomain>
	<20060412154214.1dd4117d@localhost.localdomain>
	<20060413124534.GA25333@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21136 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932134AbWDMR1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 13:27:37 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060413124534.GA25333@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 22:45:34 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Apr 12, 2006 at 03:42:14PM -0700, Stephen Hemminger wrote:
> > By inspection, the clip idle timer code is racy on SMP.
> > Here is a safe version of timer management.
> > Untested, I don't have ATM hardware.
> 
> Good catch Stephen.
> 
> > -	if (start_timer == 0)
> > -		del_timer(&idle_timer);
> > +	del_timer_sync(&idle_timer);
> 
> I don't think this is enough though since this timer is one of those
> self-rescheduling timers.  You need to provide some sort of a flag
> for it to stop scheduling itself and synchronise it properly.

Arp and neighbor table have the same rescheduling bug.

> Of course this is an existing bug but we might as well squash it
> before we forget about it.
> 
> Cheers,
