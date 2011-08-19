From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: one more case for non-local saddr in
 ICMP
Date: Fri, 19 Aug 2011 03:43:54 -0700 (PDT)
Message-ID: <20110819.034354.219449243171613725.davem@davemloft.net>
References: <alpine.LFD.2.00.1108151857420.1481@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976Ab1HSKoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 06:44:19 -0400
In-Reply-To: <alpine.LFD.2.00.1108151857420.1481@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Mon, 15 Aug 2011 19:21:23 +0300 (EEST)

> 
> 	May be there is one more case that we can avoid using
> non-local source for ICMP errors: xfrm_lookup, num_xfrms = 0 when
> reverse "Flow passes untransformed". Avoid using the input route
> if xfrm_lookup returns same dst.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	In fact, should we use local IP in all cases when
> sending ICMP? I'm asking it for the following case:
> 
> 	Large packet is forwarded but is rejected with ICMP FRAG
> NEEDED. We usually send ICMP with local saddr instead of the
> original non-local destination. What is the role of
> this reverse check? May be after xfrm_decode_session_reverse
> we should use 'fl4_dec.saddr = fl4->saddr;' so that xfrm_lookup
> works with ICMP from local IP? What is right thing to do here?
> I don't see code that looks in the embedded header...

Well.. this relookup behavior is guided by a special transform state
XFRM_STATE_ICMP that the user must explicitly create IPSEC rules for.

Presumably they are going to add real transforms to such special IPSEC
rules, not create NOP ones with no transforms.  And if they do create
such IPSEC state with no transforms, perhaps the intention is to trigger
to use of the non-local source.

The whole thing revolves around how Herbert envisions people implementing
RFC4301 support using this new XFRM_STATE_ICMP thing.

Right?

