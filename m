From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: How to use gretap with bridge?
Date: Thu, 29 Oct 2009 19:47:56 -0400
Message-ID: <20091029234756.GA1595@gondor.apana.org.au>
References: <20091029130036.1e61f415@nehalam> <846C5B546E47494CBBD796CA8CA1617EA3B439@MST-VMAIL1.srv.mst.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: "Neulinger, Nathan" <nneul@mst.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44797 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754708AbZJ2Xr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 19:47:59 -0400
Content-Disposition: inline
In-Reply-To: <846C5B546E47494CBBD796CA8CA1617EA3B439@MST-VMAIL1.srv.mst.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2009 at 05:04:02PM -0500, Neulinger, Nathan wrote:
> Now I see it - Stephen actually had it right on - the problem is that
> the gre tunnel is creating a MAC address on the fly based on the tunnel
> endpoint ip address, so if the tunnel endpoint address starts with an
> odd number, it hits the multicast check in the bridging code. (I'm sure
> that's what he meant and I just missed it entirely.)
> 
> Simplest option would probably be to just mask off the first octet with
> 0xFD or using the ip as the last four octets of the mac instead of the
> first four.

This looks like a bug in either iproute or the kernel.  It's
not supposed to set a MAC address unless the user specifically
gives one.  If one is not given the kernel will generate a valid
MAC address.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
