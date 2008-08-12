From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: csum offload and af_packet
Date: Tue, 12 Aug 2008 08:58:39 +0800
Message-ID: <20080812005839.GC18547@gondor.apana.org.au>
References: <E1KSU3v-00037r-00@gondolin.me.apana.org.au> <200808112350.25514.rusty@rustcorp.com.au> <20080812003244.GA18230@gondor.apana.org.au> <20080811.175154.168708843.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38368 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750983AbYHLA6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 20:58:49 -0400
Content-Disposition: inline
In-Reply-To: <20080811.175154.168708843.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 05:51:54PM -0700, David Miller wrote:
>
> Unfortunately the censored version doesn't allow you to get at the
> link level headers, which is what at least some of these applications
> want.

Yes that is certainly true for the DHCP server, but Rusty was
complaining about the DHCP client which certainly does not need
the LL headers on reception (although using it is definitely more
convenient since you need it on transmit anyway).

I agree that handling this in AF_PACKET is certainly possible,
and for that matter not extremely difficult.  However, my point is
that doing this for the purposes of virtualisation is completely
pointless.

The only time you need this is when you have an old guest that
you cannot modify.  If you could modify it you can always give it
a patched DHCP client (I've alread patched dhcp-client for Xen
so that should work properly for KVM/lguest if you're using the
latest version).

And if you can't modify it then patching AF_PACKET is completely
pointless since we need to do this in the guest kernel and not the
host kernel.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
