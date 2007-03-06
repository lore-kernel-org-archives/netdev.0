From: Baruch Even <baruch@ev-en.org>
Subject: Re: [RFC PATCH] [TCP]: Reworked recovery's TCPCB_LOST marking functions
Date: Wed, 7 Mar 2007 00:01:46 +0200
Message-ID: <20070306220146.GO25760@galon.ev-en.org>
References: <Pine.LNX.4.64.0703061442440.3770@kivilampi-30.cs.helsinki.fi> <20070306194259.GK25760@galon.ev-en.org> <20070306.134726.39155177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:64042
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030302AbXCFWBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 17:01:48 -0500
Content-Disposition: inline
In-Reply-To: <20070306.134726.39155177.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> [070306 23:47]:
> From: Baruch Even <baruch@ev-en.org>
> Date: Tue, 6 Mar 2007 21:42:59 +0200
> 
> > * Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi> [070306 14:52]:
> > > +		newtp->highest_sack = treq->snt_isn + 1;
> > 
> > That's the only initialization that you have for highest_sack, I think
> > that you should initialize it when a loss is detected to the start_seq
> > of the first packet that wasn't acked.
> 
> He also sets it in tcp_sacktag_write_queue() like this:
> 
> +
> +				if (after(TCP_SKB_CB(skb)->seq,
> +				    tp->highest_sack))
> +					tp->highest_sack = TCP_SKB_CB(skb)->seq;

Yes, but that's still not enough if between the start of the connection
and the first sack block we already wrapped around to before the old
highest_sack. It might not be a common occurrence but it's still
something to take care of.

Baruch
