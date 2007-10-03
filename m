From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix race in process_backlog
Date: Wed, 03 Oct 2007 16:39:02 -0700 (PDT)
Message-ID: <20071003.163902.51840119.davem@davemloft.net>
References: <1191426293.5599.27.camel@lappy>
	<20071003.145807.111205634.davem@davemloft.net>
	<20071003150519.1fd206a8@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jdike@addtoit.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56714
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751534AbXJCXjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 19:39:04 -0400
In-Reply-To: <20071003150519.1fd206a8@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 3 Oct 2007 15:05:19 -0700

> On Wed, 03 Oct 2007 14:58:07 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > Date: Wed, 03 Oct 2007 17:44:53 +0200
> > 
> > > Index: linux-2.6/net/core/dev.c
> > > ===================================================================
> > > --- linux-2.6.orig/net/core/dev.c
> > > +++ linux-2.6/net/core/dev.c
> > > @@ -2095,11 +2095,11 @@ static int process_backlog(struct napi_s
> > >  
> > >  		local_irq_disable();
> > >  		skb = __skb_dequeue(&queue->input_pkt_queue);
> > > -		local_irq_enable();
> > >  		if (!skb) {
> > > -			napi_complete(napi);
> > > +			__napi_complete(napi);
> > >  			break;
> > >  		}
> > > +		local_irq_enable();
> > 
> > What re-enables interrupts in the !skb path?
> 
> This looks like a better fix. the irq_enable is needed in both cases.

Yep, applied, thanks Peter and Stephen.
