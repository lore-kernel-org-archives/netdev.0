From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 0/14] rhashtable: Kill shift/Key netlink
 namespace/Merge jhash
Date: Mon, 16 Mar 2015 15:18:05 +1100
Message-ID: <20150316041805.GA28946@gondor.apana.org.au>
References: <20150315.013613.2034532005621627761.davem@davemloft.net>
 <20150315101004.GA21383@gondor.apana.org.au>
 <20150315104306.GA21999@gondor.apana.org.au>
 <20150316.000113.1803291537029624713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:59647 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbbCPESM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:18:12 -0400
Content-Disposition: inline
In-Reply-To: <20150316.000113.1803291537029624713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 12:01:13AM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sun, 15 Mar 2015 21:43:06 +1100
> 
> > PS I'd love to kill the indirect call on the hash but I think
> > you guys need something other than jhash for sockets.  Presumably
> > they are not exposed to untrusted parties.  But I really wonder
> > whether that is still the case given things like namespaces where
> > even root may be untrusted.
> 
> In my opinion the biggest architectural fault of rhashtables is
> these damn callbacks, look at the assembler for a simple hash
> lookup, it's disgusting.

Well if everybody used jhash the indirect call would go away...

> So essentially I think the rhashtables interface to how the keys are
> described to the user is inside out.  rhashtable should just provide
> the outer-framework, and the user should provide the minute details of
> the key hashing and comparison in something that gets expanded inline.

Sure I'll try to work something out that eliminates the indirect
calls on the fast path.

However, the indirect call is still needed for rehashing but that
should be OK since rehashing is supposed to be rare.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
