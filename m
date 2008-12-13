From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/8] tcp: Add GRO support
Date: Sat, 13 Dec 2008 13:46:45 +1100
Message-ID: <20081213024644.GB14056@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0d1-0000rd-B2@gondolin.me.apana.org.au> <20081212195615.GC27281@ioremap.net> <20081212214627.GC11046@gondor.apana.org.au> <20081213024046.GB807@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42301 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753112AbYLMCqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 21:46:50 -0500
Content-Disposition: inline
In-Reply-To: <20081213024046.GB807@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2008 at 05:40:46AM +0300, Evgeniy Polyakov wrote:
>
> So it will fail if timestamp changed? Or if some new option added?

Correct, it must remain exactly the same.  Even at 100Mbps any
sane clock frequency will result in an average of 8 packets per
clock update.  At the sort speeds (>1Gbps) at which we're targetting
this'll easily get us to 64K which is our maximum (actually it
looks like I forgot to add a check to stop this from growing beyond
64K :)

As I alluded to in the opening message, in future we can consider
a more generalised form of GRO where we end up with a super-packet
that retains individual headers which can then be refragmented as
necessary.  This would allow us to merge in the presence of timestamp
changes.  However, IMHO this isn't a killer feature for merging TCP
packets.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
