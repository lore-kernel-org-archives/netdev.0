From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv4 net-next-2.6 4/5] XFRM,IPv6: Add IRO remapping hook
	in xfrm_input()
Date: Mon, 4 Oct 2010 16:40:41 +0800
Message-ID: <20101004084041.GB17939@gondor.apana.org.au>
References: <cover.1286139128.git.arno@natisbad.org> <db067c0a2ab679dfb16c84e8509e671fa6c5cb01.1286139129.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:42160 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316Ab0JDIkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 04:40:53 -0400
Content-Disposition: inline
In-Reply-To: <db067c0a2ab679dfb16c84e8509e671fa6c5cb01.1286139129.git.arno@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 04, 2010 at 08:25:23AM +0200, Arnaud Ebalard wrote:
> Add a hook in xfrm_input() to allow IRO remapping to occur when
> an incoming packet matching an existing SA (based on SPI) with
> an unexpected destination or source address is received.
> Because IRO does not consume additional bits in a packet (that's
> the point), there is no way to demultiplex based on something
> like nh or spi. Instead, IRO input handlers (for source and
> destination address remapping) are called upon address mismatch
> during IPsec processing.
> For that to work, we rely on the fact that SPI values generated
> locally are no more linked to destination address (first patch
> of the set) and we postpone a bit the expected address check in
> xfrm_input() (inside xfrm_state_lookup() against daddr param) by
> introducing a call to the input_addr_check() handler from the
> struct xfrm_state_afinfo associated with the address family.
> 
> Signed-off-by: Arnaud Ebalard <arno@natisbad.org>

I would prefer for this check to go into x->type->input since
it does not apply to IPsec.

Just because the SPI is unique for inbound SAs, it doesn't mean
that we should ignore the destination IP address in the packet for
IPsec.

I think another way of getting what you want is to simply add
inbound SAs with a zero destination address in your case which
can then be made to match any destination IP address.  You can
then follow that up with additional checks in x->type->input.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
