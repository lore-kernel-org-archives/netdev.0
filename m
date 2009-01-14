From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/2] igb: Replace LRO with GRO
Date: Wed, 14 Jan 2009 23:36:53 +1100
Message-ID: <20090114123653.GA19257@gondor.apana.org.au>
References: <9929d2390901140349v4483bd23wac254673de591bec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45338 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756384AbZANMg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 07:36:59 -0500
Content-Disposition: inline
In-Reply-To: <9929d2390901140349v4483bd23wac254673de591bec@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>
> Ok, a couple of things...
> First is that we should have the patch in testing (most likely today,
> do not worry dave, it won't take a week)

Thanks!

> Second is I am not sure you need to keep this code wraped in CONFIG_IGB_LRO...
> 
>  #ifdef CONFIG_IGB_LRO
> -       netdev->features |= NETIF_F_LRO;
> +       netdev->features |= NETIF_F_GRO;
>  #endif

My objective is to minimise changes with respect to the current
LRO base (the e1000e was an exception, it was the only hardware
I had :)

Therefore this patch is simply trying to replace LRO with GRO
letter by letter, so to speak.  In this case, it's preserving
the semantics of the Kconfig option, i.e., if LRO was off before,
then GRO will be off too (although it can now be enabled using
ethtool without recompiling).

> Also, you left part of the lro code in igb_receive_skb and then put in
> the GRO code.  Our preference is that you mirrored what you did with
> e1000e and just replaced the main vlan_hwacel and netif_receive_skb
> calls.

No I left in the netif_receive_skb but replaced the lro calls by
the corresponding gro calls.  Again the point is to replace LRO
exactly as it is.

Later on we can make further changes.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
