From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Thu, 03 Aug 2006 21:25:00 -0400
Message-ID: <1154654700.5187.35.camel@jzny2>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
	 <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
	 <1154628302.3117.15.camel@rh4> <1154642918.5187.13.camel@jzny2>
	 <1154650197.3117.32.camel@rh4> <1154654164.5187.28.camel@jzny2>
	 <20060804011805.GA12331@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:35237 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751414AbWHDBZF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 21:25:05 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G8oR5-00030E-6L
	for netdev@vger.kernel.org; Thu, 03 Aug 2006 21:25:11 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060804011805.GA12331@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-08 at 11:18 +1000, Herbert Xu wrote:
> On Thu, Aug 03, 2006 at 09:16:04PM -0400, jamal wrote:
> > 
> > and in tg3_tx():
> > 
> >      if likely(stopped) {  
> >        // essentially no lock needed here ....
> >        prune tx ring
> >        if prunned > threshold
> >            wake
> >      } else if not stopped { 
> >           // need a lock here ...
> >          grab ring tx lock irq safe
> >          prune tx ring
> >          release ring tx lock
> >      }
> 
> The problem is that the !stopped case may be the common path for a
> lot of workloads so it'd be good to avoid taking the lock there if
> we can.

True.

Although i cant think of a clever way to do the inverse....
The heuristic i was using to avoid the lock on tx at pruning time was
knowledge that tx was not being entered at all on stop.

cheers,
jamal

