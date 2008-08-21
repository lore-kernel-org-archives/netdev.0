From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 20:58:57 +0200
Message-ID: <20080821185857.GA2665@ami.dom.local>
References: <20080821120112.GA7705@gondor.apana.org.au> <20080821121920.GD4079@ff.dom.local> <20080821122245.GA8533@gondor.apana.org.au> <20080821.052754.104318066.davem@davemloft.net> <20080821123538.GA8703@gondor.apana.org.au> <20080821124834.GA8794@gondor.apana.org.au> <20080821125501.GF4079@ff.dom.local> <20080821131218.GA9208@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.189]:59383 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756166AbYHUS6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 14:58:35 -0400
Received: by gv-out-0910.google.com with SMTP id e6so50611gvc.37
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 11:58:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821131218.GA9208@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 11:12:18PM +1000, Herbert Xu wrote:
> On Thu, Aug 21, 2008 at 12:55:01PM +0000, Jarek Poplawski wrote:
> > 
> > Alas I've to have a break now, anyway I think for now "my" proposal
> > should be safer since it worked like this before... But of course
> > after good checking your patch should be better.
> 
> Well your patch doesn't work and my patch doesn't compile :)
> 
> The problem is that qdisc_lookup walks through every txq's list while
> the sch_tree_lock protects a single txq only.

I don't think there is such a problem. I thought you and David were
concerned with something trying to find and use this qdisc: that's why
I wrote it's nobody ancestor at the moment. sch_tree_lock() should be
enough for now because in the current implementation we have only one
root qdisc with pointers copied to every dev_queue. At least I can't
see nothing more in qdisc_create() and qdisc_graft(). So,
qdisc_lookup() seems to be designed for the future (or to do this
lookup more exactly with additional loops...). 

Cheers,
Jarek P.
