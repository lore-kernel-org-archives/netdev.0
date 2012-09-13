From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 3/8 (V2)] stmmac: add the initial tx coalesce
 schema
Date: Thu, 13 Sep 2012 21:42:51 +0100
Message-ID: <1347568971.13258.19.camel@deadeye.wl.decadent.org.uk>
References: <1347346514-23411-1-git-send-email-peppe.cavallaro@st.com>
	 <1347346514-23411-4-git-send-email-peppe.cavallaro@st.com>
	 <20120913.162333.1518469374321928795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43177 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754653Ab2IMUmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:42:55 -0400
In-Reply-To: <20120913.162333.1518469374321928795.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-13 at 16:23 -0400, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Tue, 11 Sep 2012 08:55:09 +0200
> 
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&priv->tx_lock, flags);
> >  
> > -	spin_lock(&priv->tx_lock);
> > +	priv->xstats.tx_clean++;
> 
> You are changing the locking here for the sake of the new timer.
> 
> But timers run in software interrupt context, so this change is
> completely unnecessary since NAPI runs in software interrupt context
> as well, and neither timers nor NAPI run in hardware interrupts
> context.

NAPI pollers can be called by netpoll in hardware interrupt context, and
this driver supports netpoll.

Ben.

> Therefore, disabling hardware interrupts for this lock is unnecessary
> and will decrease performance.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
