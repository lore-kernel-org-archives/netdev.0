From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git 3/8 (V2)] stmmac: add the initial tx coalesce
 schema
Date: Thu, 13 Sep 2012 16:46:45 -0400 (EDT)
Message-ID: <20120913.164645.1268091771093604148.davem@davemloft.net>
References: <1347346514-23411-4-git-send-email-peppe.cavallaro@st.com>
	<20120913.162333.1518469374321928795.davem@davemloft.net>
	<1347568971.13258.19.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419Ab2IMUqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:46:47 -0400
In-Reply-To: <1347568971.13258.19.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 13 Sep 2012 21:42:51 +0100

> On Thu, 2012-09-13 at 16:23 -0400, David Miller wrote:
>> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
>> Date: Tue, 11 Sep 2012 08:55:09 +0200
>> 
>> > +	unsigned long flags;
>> > +
>> > +	spin_lock_irqsave(&priv->tx_lock, flags);
>> >  
>> > -	spin_lock(&priv->tx_lock);
>> > +	priv->xstats.tx_clean++;
>> 
>> You are changing the locking here for the sake of the new timer.
>> 
>> But timers run in software interrupt context, so this change is
>> completely unnecessary since NAPI runs in software interrupt context
>> as well, and neither timers nor NAPI run in hardware interrupts
>> context.
> 
> NAPI pollers can be called by netpoll in hardware interrupt context, and
> this driver supports netpoll.

And the netpoll handler need to make amends to make sure that
hardware the environment expected by the software interrupt
code is preserved.

Well written NAPI drivers never need to disable hardware interrupts
in their ->poll() method and it's callers, neither should you.

I'm not considering your patches until you implement this properly.
