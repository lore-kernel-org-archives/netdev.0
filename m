From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] napi: limit GRO latency
Date: Mon, 8 Oct 2012 12:12:48 -0700
Message-ID: <20121008121248.783e6dc4@nehalam.linuxnetplumber.net>
References: <1349718955.21172.3534.camel@edumazet-glaptop>
	<1349719006.21172.3537.camel@edumazet-glaptop>
	<20121008115835.3a3bfed6@nehalam.linuxnetplumber.net>
	<20121008.151035.1665672334154033755.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, rick.jones2@hp.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42108 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753498Ab2JHTNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 15:13:31 -0400
In-Reply-To: <20121008.151035.1665672334154033755.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 08 Oct 2012 15:10:35 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 8 Oct 2012 11:58:35 -0700
> 
> > Limit the latency of pending GRO in NAPI processing to 2*HZ.
> > When the system is under heavy network load, NAPI will go into
> > poll mode via soft irq, and only stay in the loop for
> > two jiffies. If this occurs, process the GRO pending list
> > to make sure and not delay outstanding TCP frames for too long.
> > 
> > Rearrange the exit path to get rid of unnecessary goto logic.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Did you see Eric's patch I just applied which limits it to 1ms?

Think this is a different problem.
After leaving softirq, it may be a long time until
ksoftirqd is run which is a different problem.
