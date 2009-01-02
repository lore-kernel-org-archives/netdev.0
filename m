From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [UNTESTED] Add hardware-assisted VLAN support for GRO
Date: Fri, 2 Jan 2009 16:49:21 +1100
Message-ID: <20090102054921.GA23174@gondor.apana.org.au>
References: <20090102054714.GA23106@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:53171 "EHLO arnor.apana.org.au"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751105AbZABFuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2009 00:50:10 -0500
Received: from gondolin.me.apana.org.au ([192.168.0.6])
	by arnor.apana.org.au with esmtp (Exim 4.63 #1 (Debian))
	id 1LIcuQ-000785-Gr
	for <netdev@vger.kernel.org>; Fri, 02 Jan 2009 16:49:22 +1100
Received: from herbert by gondolin.me.apana.org.au with local (Exim 4.69)
	(envelope-from <herbert@gondor.apana.org.au>)
	id 1LIcuP-000625-G6
	for netdev@vger.kernel.org; Fri, 02 Jan 2009 16:49:21 +1100
Content-Disposition: inline
In-Reply-To: <20090102054714.GA23106@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 02, 2009 at 04:47:14PM +1100, Herbert Xu wrote:
>
> vlan: Add GRO interfaces
> 
> This patch adds GRO interfaces for hardware-assisted VLAN reception.
> With this in place we're now at parity with LRO as far as the
> interface is concerned.  That is, you can now take any LRO driver
> and convert it over to GRO.

Here's an updated description for the 2nd patch:

vlan: Add GRO interfaces

This patch adds GRO interfaces for hardware-assisted VLAN reception.
With this in place we're now at parity with LRO as far as the
interface is concerned.  That is, you can now take any LRO driver
and convert it over to GRO.

As the CB memory clashes with GRO's use of CB, I've removed it
entirely by storing dev in skb->dev.  This is OK because VLAN
gets called first thing in netif_receive_skb and skb->dev is
not used in between us calling netif_rx and netif_receive_skb
getting called.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
