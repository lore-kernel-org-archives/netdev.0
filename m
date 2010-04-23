From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Fri, 23 Apr 2010 10:10:00 +0800
Message-ID: <20100423021000.GA21777@gondor.apana.org.au>
References: <20100422.004324.67422011.davem@davemloft.net> <20100422142506.GA15858@gondor.apana.org.au> <20100422154908.GA31568@midget.suse.cz> <20100422.185400.71096585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbohac@suse.cz, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:33427 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752740Ab0DWCKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 22:10:15 -0400
Content-Disposition: inline
In-Reply-To: <20100422.185400.71096585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 06:54:00PM -0700, David Miller wrote:
> From: Jiri Bohac <jbohac@suse.cz>
> Date: Thu, 22 Apr 2010 17:49:08 +0200
> 
> > I still don't see why __ipv6_ifa_notify() needs to call
> > dst_free(). Shouldn't that be dst_release() instead, to drop the
> > reference obtained by dst_hold(&ifp->rt->u.dst)?
> 
> It likely wants to do both.

Actually I don't think the problem is in __ipv6_ifa_notify.  The
fact is none of this stuff is meant to be idempotent.  So it's
up to the entity that is requesting the deletion to make sure that
a single object is not deleted more than once.

Yes the original symptom was in __ipv6_ifa_notify, but it is
merely pointing out that we have a problem further up.

My patch is indeed not sufficient as Jiri pointed out, because
I didn't deal with the case of an administrative deletion of
autmatically generated IPv6 addresses.

I will post an updated patch later today to deal with that.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
