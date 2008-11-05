From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tbench wrt. loopback TSO
Date: Wed, 5 Nov 2008 14:04:14 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811051355550.23792@wrl-59.cs.helsinki.fi>
References: <20081027.113904.211811887.davem@davemloft.net>
 <20081105.034224.167388197.davem@davemloft.net> <20081105114900.GA18691@ioremap.net>
 <20081105.035454.87914782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, Netdev <netdev@vger.kernel.org>, efault@gmx.de,
	mingo@elte.hu, a.p.zijlstra@chello.nl,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50717 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755465AbYKEMEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 07:04:16 -0500
In-Reply-To: <20081105.035454.87914782.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Nov 2008, David Miller wrote:

> From: Evgeniy Polyakov <zbr@ioremap.net>
> Date: Wed, 5 Nov 2008 14:49:00 +0300
> 
> > But what if we just remove that trimming at all? This may result in
> > a not fully filled tso frame, but who cares if we copy data from
> > userspace anyway, will add another potentially small copy at sending
> > time?
> 
> Ok, the only part I care about is whether taking away this modulus
> will result in a sub-MSS sized packet on the wire, which is
> undesirable.
>
> The send logic will prevent this, right?

I don't see what currently would do that. We'd need to resegment skbs 
there then...

> If so, yes I agree, we can delete this.

Would we have something similar to those blobs we discussed when talking 
about sack data structures it might be provided by machinery we need 
anyway but currently it gets quite non-trivial since in order to fill a 
segment we need to input from two skb's which probably requires making 
another skb or the stack downstream cannot cope afaik.

-- 
 i.
