From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Fri, 23 Apr 2010 23:05:40 +0800
Message-ID: <20100423150540.GA26611@gondor.apana.org.au>
References: <20100422.004324.67422011.davem@davemloft.net> <20100422142506.GA15858@gondor.apana.org.au> <20100422154908.GA31568@midget.suse.cz> <20100422.185400.71096585.davem@davemloft.net> <20100423021000.GA21777@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbohac@suse.cz, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:56031 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755476Ab0DWPFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 11:05:51 -0400
Content-Disposition: inline
In-Reply-To: <20100423021000.GA21777@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 23, 2010 at 10:10:00AM +0800, Herbert Xu wrote:
> 
> I will post an updated patch later today to deal with that.

Just got back from a business trip.

This stuff is more broken than I thought.  For example, we perform
a number of actions when DAD succeeds, e.g., joining an anycast
group.  However, this is not synchronised with respect to address
deletion at all, so if DAD succeeds just as someone deletes the
address, you can easily get stuck on that anycast group.

I will try to untangle this mess tomorrow.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
