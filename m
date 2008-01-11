From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Fri, 11 Jan 2008 11:00:20 +1100
Message-ID: <20080111000020.GB22040@gondor.apana.org.au>
References: <20080109113727.50eae500.dada1@cosmosbay.com> <20080110231042.GA3199@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3608 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751622AbYAKABH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 19:01:07 -0500
Content-Disposition: inline
In-Reply-To: <20080110231042.GA3199@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2008 at 12:10:42AM +0100, Jarek Poplawski wrote:
>
> It seems this optimization could've a side effect: if during such a
> loop updates are done, and r is seen !NULL during while() check, but
> NULL after rcu_dereference(), the listing/counting could stop too
> soon. So, IMHO, probably the first version of this patch is more
> reliable. (Or alternatively additional check is needed before return.)

No, while the value of r->u.dst.rt_next can change between two readings,
the value of r cannot.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
