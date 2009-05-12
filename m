From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: question about softirqs
Date: Tue, 12 May 2009 08:20:51 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0905120818290.13234@gandalf.stny.rr.com>
References: <18948.63755.279732.294842@cargo.ozlabs.ibm.com>  <20090508.234815.127227651.davem@davemloft.net>  <4A086DB2.8040703@nortel.com>  <20090511.162436.193717082.davem@davemloft.net>  <4A08C62F.1050105@nortel.com> <20090512081237.GA16403@elte.hu>
 <1242119578.11251.321.camel@twins>  <20090512092348.GA29796@elte.hu> <1242120761.11251.324.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>, Chris Friesen <cfriesen@nortel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, netdev@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.123]:33454 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbZELMUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 08:20:53 -0400
In-Reply-To: <1242120761.11251.324.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 12 May 2009, Peter Zijlstra wrote:

> On Tue, 2009-05-12 at 11:23 +0200, Ingo Molnar wrote:
> > 
> > Yeah, that would be "nice". A single IRQ thread plus the process 
> > context(s) doing networking might perform well.
> > 
> > Multiple IRQ threads (softirq and hardirq threads mixed) i'm not so 
> > sure about - it's extra context-switching cost.
> 
> Sure, that was implied by the getting rid of softirqs ;-), on -rt we
> currently suffer this hardirq/softirq thread ping-pong, it sucks.

I'm going to be playing around with bypassing the net-rx/tx with my 
network drivers. I'm going to add threaded irqs for my network cards and 
have the driver threads do the work to get through the tcp/ip stack.

I'll still keep the softirqs for other cards, but I want to see how fast 
it speeds things up if I have the driver thread do it.

-- Steve

