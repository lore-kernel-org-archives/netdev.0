From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv4 net-next-2.6 4/5] XFRM,IPv6: Add IRO remapping hook
	in xfrm_input()
Date: Wed, 6 Oct 2010 09:25:09 +0800
Message-ID: <20101006012509.GA3540@gondor.apana.org.au>
References: <cover.1286139128.git.arno@natisbad.org> <db067c0a2ab679dfb16c84e8509e671fa6c5cb01.1286139129.git.arno@natisbad.org> <20101004084041.GB17939@gondor.apana.org.au> <87vd5h7kbh.fsf@small.ssi.corp> <20101005062732.GA27337@gondor.apana.org.au> <878w2cfcd1.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44671 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719Ab0JFBZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 21:25:23 -0400
Content-Disposition: inline
In-Reply-To: <878w2cfcd1.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 06, 2010 at 01:28:42AM +0200, Arnaud Ebalard wrote:
>
>  1) First, current net-next-2.6 (no patches applied)
>  2) then, with my patches applied and CONFIG_XFRM_SUB_POLICY enabled
>  3) then, with my patches applied and CONFIG_XFRM_SUB_POLICY disabled

To measure the effect of this properly you should use null
encryption/hashing and look at the CPU utilisation with minimum
packet sizes.
 
> > With your remapping, would it be possible to add dummy xfrm_state
> > objects with the remapped destination address that could then call
> > xfrm6_input_addr?
> >
> > That way normal IPsec users would not be affected at all while
> > preserving your new functionality.
> 
> I don't think I can do that easily (at all?) with what XFRM provides,
> can I? Or at least I don't see how it is possible because I would need
> some kind of policy for the state to be applied and the only trigger I
> see is the src/dst address mismatch when processing the IPsec packet.

So do you know the remapped destination addresses a priori?

If not then then other possibility would be to add the code hook
in case of xfrm_state_lookup failure.

But more importantly you need to solve the hash collission issue
that I mentioned earlier.  Without that it won't work at all.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
