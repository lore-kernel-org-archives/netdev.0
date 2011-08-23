From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] ipv4: one more case for non-local saddr in
	ICMP
Date: Tue, 23 Aug 2011 14:46:40 +0800
Message-ID: <20110823064640.GA6174@gondor.apana.org.au>
References: <alpine.LFD.2.00.1108151857420.1481@ja.ssi.bg> <20110819.034354.219449243171613725.davem@davemloft.net> <20110820082048.GA15169@gondor.apana.org.au> <alpine.LFD.2.00.1108230845510.1565@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:47528 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749Ab1HWGqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 02:46:48 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1108230845510.1565@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 23, 2011 at 09:34:45AM +0300, Julian Anastasov wrote:
>
> 	I just notice that if original packet (say TCP) hits
> "fwd" policy, for the locally generated ICMP error we call
> xfrm_lookup with sk = NULL and it always uses "out" dir
> for the flow_cache_lookup call to search for this reverse SA.
> So, we must be prepared with rules in "out" dir even for
> the forwarding case? icmp flag in "fwd" rules is not considered?

This is a common question about our IPsec stack.  Both fwd
and in are used for ingress, with the only difference being
whether the packet is locally destined or not.  Only out is
used for egress traffic.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
