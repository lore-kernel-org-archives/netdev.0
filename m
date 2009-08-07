From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Fri, 7 Aug 2009 08:23:02 -0400
Message-ID: <200908070823.03046.paul.moore@hp.com>
References: <20090803161242.12947.14620.stgit@flek.lan> <200908061420.20983.paul.moore@hp.com> <20090807000021.GA1566@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:9669 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371AbZHGMXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 08:23:08 -0400
In-Reply-To: <20090807000021.GA1566@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 August 2009 08:00:21 pm Herbert Xu wrote:
> On Thu, Aug 06, 2009 at 02:20:20PM -0400, Paul Moore wrote:
> > The code currently looks something like this:
> >
> > 	err = -ENOMEM;
> > 	buf = alloc(...);
> > 	if (!buf)
> > 		goto label;
> >
> > This means that in the common case where 'alloc()' completes without
> > error we are doing an extra, unnecessary assignment where we set the
> > value in 'err'. Now, if we change this slightly to match what I proposed
> > in the patch:
> >
> > 	buf = alloc(...);
> > 	if (!buf) {
> > 		err = -ENOMEM;
> > 		goto label;
> > 	}
> >
> > We eliminate that extra assignment in the case where 'alloc()' completes
> > without error, which should result in more efficient code (less
> > instructions in the common case).  Am I wrong?  If that is the case I
> > would appreciate an explanation ...
>
> Your style potentially introduces a second jump which may end
> up being worse compared to the extra work on a modern CPU.

Thanks, I hadn't thought of that possibility.  I suppose the impact of a 
second jump is going to depend quite a bit on the hardware it runs on 
(pipeline depth, branch prediction, etc.) and isn't as easy to quantify as I 
had hoped.  Oh well, I appreciate the explanation anyway :)

-- 
paul moore
linux @ hp

