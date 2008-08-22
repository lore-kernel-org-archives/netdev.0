From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 04:42:48 -0700 (PDT)
Message-ID: <20080822.044248.175133807.davem@davemloft.net>
References: <20080821185857.GA2665@ami.dom.local>
	<20080821222330.GE14521@gondor.apana.org.au>
	<20080822113833.GA14981@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51698
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752314AbYHVLmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 07:42:50 -0400
In-Reply-To: <20080822113833.GA14981@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 22 Aug 2008 11:38:33 +0000

> On Fri, Aug 22, 2008 at 08:23:30AM +1000, Herbert Xu wrote:
> > On Thu, Aug 21, 2008 at 08:58:57PM +0200, Jarek Poplawski wrote:
> > >
> > > root qdisc with pointers copied to every dev_queue. At least I can't
> > > see nothing more in qdisc_create() and qdisc_graft(). So,
> > > qdisc_lookup() seems to be designed for the future (or to do this
> > > lookup more exactly with additional loops...). 
> > 
> > We've got at least the RX and TX queues.  That makes two locks and
> > two lists.
> 
> As a matter of fact your doubts around this enlightened me only now
> there is something "wrong" here... This qdisc_lookup(), even if
> there were all these multi RX and TX things implemented, still
> shouldn't matter because what qdisc_tree_decrease_qlen() could be
> interested in is only one qdisc tree. So it looks like current
> implementation of qdisc_lookup() is an overkill for this anyway.

Yes, that is true.

We could add true parent backpointers for this.  Speaking of which,
look at the existing __parent hack that's there in struct Qdisc for
CBQ :-)
