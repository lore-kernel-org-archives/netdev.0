From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]: fix lro_gen_skb() alignment
Date: Sat, 1 Dec 2007 09:34:57 +1100
Message-ID: <20071130223457.GA25388@gondor.apana.org.au>
References: <E1Iy2ey-0005eY-00@gondolin.me.apana.org.au> <475057E4.3000909@myri.com> <ada3aunlf4s.fsf@cisco.com> <4750660F.7000704@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier@cisco.com>, davem@davemloft.net,
	ossthema@de.ibm.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2015 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752386AbXK3Wff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 17:35:35 -0500
Content-Disposition: inline
In-Reply-To: <4750660F.7000704@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 30, 2007 at 02:35:43PM -0500, Andrew Gallatin wrote:
>
> >Isn't the value of 2 ethernet-specific (to round the 14-byte header up
> >to 16)?  Given that the rest of the lro code is fairly careful to
> >calculate mac_hdr_len etc it seems as if it would be cleaner to make
> >this independent of the specific L2 being used.
> >
> >(And I plan on using the LRO module for IP-over-InfiniBand so this is
> >not completely theoretical)

Good point!

We really should rename NET_IP_ALIGN so that both Ethernet and DMA
occur in it somehow :)

> Good point.  I tend to think all the world is ethernet.
> Perhaps the better way would be to simply add an alignment pad
> field to lro_mgr?  When the driver initializes it, it specifies
> any padding needed.  Ethernet drivers would specify 2.

Just pass in the mac_hdr_len, and calculate the padding as

	ALIGN(mac_hdr_len, 4) - mac_hdr_len

or even simpler

	~(mac_hdr_len - 1) & 3

Bonus points for putting this in a macro alongside NET_IP_ALIGN :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
