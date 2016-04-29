From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv2] netem: Segment GSO packets on enqueue.
Date: Thu, 28 Apr 2016 21:20:24 -0400
Message-ID: <20160429012024.GA24715@neilslaptop.think-freely.org>
References: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
 <1461874148-14937-1-git-send-email-nhorman@tuxdriver.com>
 <1461877133.5535.119.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netem@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48002 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbcD2BUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 21:20:53 -0400
Content-Disposition: inline
In-Reply-To: <1461877133.5535.119.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 01:58:53PM -0700, Eric Dumazet wrote:
> On Thu, 2016-04-28 at 16:09 -0400, Neil Horman wrote:
> > This was recently reported to me, and reproduced on the latest net kernel, when
> > attempting to run netperf from a host that had a netem qdisc attached to the
> > egress interface:
> 
> >  
> > -	return NET_XMIT_SUCCESS;
> > +finish_segs:
> > +	while (segs) {
> > +		skb2 = segs->next;
> > +		segs->next = NULL;
> > +		qdisc_skb_cb(segs)->pkt_len = segs->len;
> > +		rc = qdisc_enqueue(segs, sch);
> > +		if (rc != NET_XMIT_SUCCESS) {
> > +			if (net_xmit_drop_count(rc))
> > +				qdisc_qstats_drop(sch);
> > +		}
> > +		segs = skb2;
> > +	}
> > +	return rc;
> >  }
> 
> It seems you missed the qdisc_tree_reduce_backlog() call ?
> 
Crap, yes, sorry.  I did a last minute modification to move the segment
requeuing to netem_enqueue and inadvertently remove it, I'll repost shortly.

Best
Neil

> 
> 
> 
