From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 12:09:18 +0000
Message-ID: <20080822120918.GB14981@ff.dom.local>
References: <20080821185857.GA2665@ami.dom.local> <20080821222330.GE14521@gondor.apana.org.au> <20080822113833.GA14981@ff.dom.local> <20080822.044248.175133807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:64103 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbYHVMJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 08:09:57 -0400
Received: by ug-out-1314.google.com with SMTP id c2so118284ugf.37
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 05:09:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080822.044248.175133807.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 04:42:48AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 22 Aug 2008 11:38:33 +0000
> 
> > On Fri, Aug 22, 2008 at 08:23:30AM +1000, Herbert Xu wrote:
> > > On Thu, Aug 21, 2008 at 08:58:57PM +0200, Jarek Poplawski wrote:
> > > >
> > > > root qdisc with pointers copied to every dev_queue. At least I can't
> > > > see nothing more in qdisc_create() and qdisc_graft(). So,
> > > > qdisc_lookup() seems to be designed for the future (or to do this
> > > > lookup more exactly with additional loops...). 
> > > 
> > > We've got at least the RX and TX queues.  That makes two locks and
> > > two lists.
> > 
> > As a matter of fact your doubts around this enlightened me only now
> > there is something "wrong" here... This qdisc_lookup(), even if
> > there were all these multi RX and TX things implemented, still
> > shouldn't matter because what qdisc_tree_decrease_qlen() could be
> > interested in is only one qdisc tree. So it looks like current
> > implementation of qdisc_lookup() is an overkill for this anyway.
> 
> Yes, that is true.
> 
> We could add true parent backpointers for this.  Speaking of which,
> look at the existing __parent hack that's there in struct Qdisc for
> CBQ :-)

I guess, we need to establish first how much it's needed on fast
paths. But anyway, it seems something like qdisc_match_from_root()
should be enough in this qdisc_tree_decrease_qlen().

Jarek P.
