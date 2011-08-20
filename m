From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] ipv4: one more case for non-local saddr in
	ICMP
Date: Sat, 20 Aug 2011 16:20:48 +0800
Message-ID: <20110820082048.GA15169@gondor.apana.org.au>
References: <alpine.LFD.2.00.1108151857420.1481@ja.ssi.bg> <20110819.034354.219449243171613725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54088 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293Ab1HTIU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 04:20:57 -0400
Content-Disposition: inline
In-Reply-To: <20110819.034354.219449243171613725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2011 at 03:43:54AM -0700, David Miller wrote:
> From: Julian Anastasov <ja@ssi.bg>
> Date: Mon, 15 Aug 2011 19:21:23 +0300 (EEST)
> 
> > 
> > 	May be there is one more case that we can avoid using
> > non-local source for ICMP errors: xfrm_lookup, num_xfrms = 0 when
> > reverse "Flow passes untransformed". Avoid using the input route
> > if xfrm_lookup returns same dst.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> > 
> > 	In fact, should we use local IP in all cases when
> > sending ICMP? I'm asking it for the following case:
> > 
> > 	Large packet is forwarded but is rejected with ICMP FRAG
> > NEEDED. We usually send ICMP with local saddr instead of the
> > original non-local destination. What is the role of
> > this reverse check? May be after xfrm_decode_session_reverse
> > we should use 'fl4_dec.saddr = fl4->saddr;' so that xfrm_lookup
> > works with ICMP from local IP? What is right thing to do here?
> > I don't see code that looks in the embedded header...
> 
> Well.. this relookup behavior is guided by a special transform state
> XFRM_STATE_ICMP that the user must explicitly create IPSEC rules for.
> 
> Presumably they are going to add real transforms to such special IPSEC
> rules, not create NOP ones with no transforms.  And if they do create
> such IPSEC state with no transforms, perhaps the intention is to trigger
> to use of the non-local source.
> 
> The whole thing revolves around how Herbert envisions people implementing
> RFC4301 support using this new XFRM_STATE_ICMP thing.
> 
> Right?

The intention of XFRM_STATE_ICMP is to automatically allow inbound
IPsec-protected ICMP packets (remember that IPsec tunnels are not
automatically allowed, as that opens room for address spoofing).

Imagine if you have a policy P that allows IPsec packets with inner
addresses going from S to D.  The purpose of this is to ensure that
ICMP packets from D to S are automatically allowed.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
