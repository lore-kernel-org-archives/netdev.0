From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Fri, 4 Aug 2006 11:18:05 +1000
Message-ID: <20060804011805.GA12331@gondor.apana.org.au>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au> <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com> <1154628302.3117.15.camel@rh4> <1154642918.5187.13.camel@jzny2> <1154650197.3117.32.camel@rh4> <1154654164.5187.28.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44553 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751415AbWHDBSK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 21:18:10 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154654164.5187.28.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 09:16:04PM -0400, jamal wrote:
> 
> and in tg3_tx():
> 
>      if likely(stopped) {  
>        // essentially no lock needed here ....
>        prune tx ring
>        if prunned > threshold
>            wake
>      } else if not stopped { 
>           // need a lock here ...
>          grab ring tx lock irq safe
>          prune tx ring
>          release ring tx lock
>      }

The problem is that the !stopped case may be the common path for a
lot of workloads so it'd be good to avoid taking the lock there if
we can.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
