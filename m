From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] [TCP]: Reworked recovery's TCPCB_LOST marking
 functions
Date: Tue, 06 Mar 2007 14:02:24 -0800 (PST)
Message-ID: <20070306.140224.51861921.davem@davemloft.net>
References: <20070306194259.GK25760@galon.ev-en.org>
	<20070306.134726.39155177.davem@davemloft.net>
	<20070306220146.GO25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51154
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030299AbXCFWC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 17:02:27 -0500
In-Reply-To: <20070306220146.GO25760@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Wed, 7 Mar 2007 00:01:46 +0200

> * David Miller <davem@davemloft.net> [070306 23:47]:
> > From: Baruch Even <baruch@ev-en.org>
> > Date: Tue, 6 Mar 2007 21:42:59 +0200
> > 
> > > * Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi> [070306 14:52]:
> > > > +		newtp->highest_sack = treq->snt_isn + 1;
> > > 
> > > That's the only initialization that you have for highest_sack, I think
> > > that you should initialize it when a loss is detected to the start_seq
> > > of the first packet that wasn't acked.
> > 
> > He also sets it in tcp_sacktag_write_queue() like this:
> > 
> > +
> > +				if (after(TCP_SKB_CB(skb)->seq,
> > +				    tp->highest_sack))
> > +					tp->highest_sack = TCP_SKB_CB(skb)->seq;
> 
> Yes, but that's still not enough if between the start of the connection
> and the first sack block we already wrapped around to before the old
> highest_sack. It might not be a common occurrence but it's still
> something to take care of.

Aha, I see, yes good point.  That would need to be fixed.
