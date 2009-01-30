From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Fri, 30 Jan 2009 17:57:21 +1100
Message-ID: <20090130065721.GA4886@gondor.apana.org.au>
References: <adaljsvwbkm.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, aluno3@poczta.onet.pl,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55711 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751069AbZA3G5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 01:57:44 -0500
Content-Disposition: inline
In-Reply-To: <adaljsvwbkm.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier <rdreier@cisco.com> wrote:
> 
> OK, thanks... what confused me is that several other drivers also do
> skb_linearize() in their hard_start_xmit method... eg bnx2x,
> via-velocity, mv643xx_eth.  So there are several other lurking bugs to
> deal with here I guess.

I don't know about the rest but bnx2x is certainly OK since it
only does so with IRQ enabled.  It is legal to call skb_linearize
as long as you're sure that IRQs are enabled, which is always the
case for hard_start_xmit upon entry.

So the only time you can't call it in hard_start_xmit is if you've
just disabled IRQs yourself.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
