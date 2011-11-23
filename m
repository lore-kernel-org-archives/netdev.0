From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] ipv4: Don't use the cached pmtu informations for
 input routes
Date: Wed, 23 Nov 2011 16:49:41 -0500 (EST)
Message-ID: <20111123.164941.1950228526500366081.davem@davemloft.net>
References: <20111123121450.GE6348@secunet.com>
	<20111123155245.GA11638@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283Ab1KWVt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 16:49:57 -0500
In-Reply-To: <20111123155245.GA11638@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Wed, 23 Nov 2011 23:52:45 +0800

> Steffen Klassert <steffen.klassert@secunet.com> wrote:
>> The pmtu informations on the inetpeer are visible for output and
>> input routes. On packet forwarding, we might propagate a learned
>> pmtu to the sender. As we update the pmtu informations of the
>> inetpeer on demand, the original sender of the forwarded packets
>> might never notice when the pmtu to that inetpeer increases.
>> So use the mtu of the outgoing device on packet forwarding instead
>> of the pmtu to the final destination.
> 
> I disagree.  MTU increases are detected by the source retrying,
> so they most certainly should notice if our cached value expires.

Herbert, consider the issue one level higher :-)

The issue is that "we", the forwarding entity, end up with a cached on
the input route and report this cached PMTU to the sender.

This takes a while to time out.

So even if the sender "probes" he will be kept from seeing new MTU space
becomming available due to our cached value.

What Steffen is doing is simply re-instating the behavior we had
before the inetpeer conversion occurred.  We never used learned PMTU
information on input routes, only output routes stored them.

But now that input and output routes share learned information from
the same set of inetpeer entries, we have to accomodate cases like this
one.
