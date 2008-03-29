From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Sat, 29 Mar 2008 10:11:01 +0100
Message-ID: <20080329091101.GA3407@ami.dom.local>
References: <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <47EC50BA.6080908@sun.com> <20080328103809.GB23039@gondor.apana.org.au> <20080328133845.GA14565@ami.dom.local> <20080328135338.GA24374@gondor.apana.org.au> <20080328143953.GA14642@ami.dom.local> <20080328145634.GA24712@gondor.apana.org.au> <20080328152953.GB14642@ami.dom.local> <20080329010610.GA27652@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matheos Worku <Matheos.Worku@Sun.COM>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:3820 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbYC2JGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 05:06:52 -0400
Received: by ug-out-1314.google.com with SMTP id z38so62849ugc.16
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2008 02:06:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080329010610.GA27652@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 29, 2008 at 09:06:10AM +0800, Herbert Xu wrote:
> On Fri, Mar 28, 2008 at 04:29:53PM +0100, Jarek Poplawski wrote:
> >
> > But during this, now limited, time of qdisc_run() there is a contention
> > for queue_lock and probably some additional cache updating because of
> > this other enqueuing, which could be delayed especially if queue length
> > is above some level.
> 
> You mean delaying into a per-cpu queue? That sounds interesting.

I mean any delaying could be necessary here. After rethinking it seems
to me this solution with the flag could be wrong even after current fix.

The owner of the flag has to give up queue_lock for some time, and
because of this its chances for regaining the lock are worse: other CPUs
could take it in a loop, winning the cache, and adding packets, which
are imediately dumped (or requeued).

So, it would make a kind of reverse lockup situation. Then, even normal
contention for both locks seems safer against such races: throughput
could be worse, but probably no such "(soft)lockup" risk.

Regards,
Jarek P.
