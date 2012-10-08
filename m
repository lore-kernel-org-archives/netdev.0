From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] napi: limit GRO latency
Date: Mon, 08 Oct 2012 21:30:12 +0200
Message-ID: <1349724612.21172.3643.camel@edumazet-glaptop>
References: <1349718955.21172.3534.camel@edumazet-glaptop>
	 <1349719006.21172.3537.camel@edumazet-glaptop>
	 <20121008115835.3a3bfed6@nehalam.linuxnetplumber.net>
	 <20121008.151035.1665672334154033755.davem@davemloft.net>
	 <20121008121248.783e6dc4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	jesse@nicira.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38108 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab2JHTaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 15:30:25 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2242869bkc.19
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2012 12:30:24 -0700 (PDT)
In-Reply-To: <20121008121248.783e6dc4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-08 at 12:12 -0700, Stephen Hemminger wrote:
> On Mon, 08 Oct 2012 15:10:35 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Mon, 8 Oct 2012 11:58:35 -0700
> > 
> > > Limit the latency of pending GRO in NAPI processing to 2*HZ.
> > > When the system is under heavy network load, NAPI will go into
> > > poll mode via soft irq, and only stay in the loop for
> > > two jiffies. If this occurs, process the GRO pending list
> > > to make sure and not delay outstanding TCP frames for too long.
> > > 
> > > Rearrange the exit path to get rid of unnecessary goto logic.
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > Did you see Eric's patch I just applied which limits it to 1ms?
> 
> Think this is a different problem.
> After leaving softirq, it may be a long time until
> ksoftirqd is run which is a different problem.

System is under stress, you dont want to increase load at this point,
but increase bandwidth.

Really try this on a 40Gbe link and see how bad it is.

On a server, we probably dedicate one or several cpus only to run NAPI,
so yes we hit net_rx_action() break, but we'll reenter it a few us
later.
