From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Thu, 10 May 2007 22:59:28 +1000
Message-ID: <E1Hm8Ey-0006oe-00@gondolin.me.apana.org.au>
References: <1178799661.4074.20.camel@localhost>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	krkumar2@in.ibm.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3160 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755347AbXEJM7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 08:59:47 -0400
In-Reply-To: <1178799661.4074.20.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> wrote:
> 
> Ok, see if this makes sense:
> 
> CPU0                 CPU1 (holding qdisc running)
>  .                    |
>  .                    |
>  .                    + grab qlock
>  .                    |
>  .                    | deq pkt
>  .                    + release qlock
>  .                    + grab txlock
>  .                    |  send pkt
>  .                    + release txlock
>  .                    + grab qlock
>   has pktX            | (NEW: qlen = 0); return 0 instead of -1
>   waiting for qlock   + release qlock

			This release qlock isn't in our source code :)

>  + grab qlock         |
>  |                    + find that return code is 0
>  | enq pkt X          + release qdisc running
>  |                    |
>  + release qlock      | ==> outta here
> 
> pkt X is stuck unless some event happens such as a new pkt arrival. 
> In other words it sits there for an indeterminate period.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
