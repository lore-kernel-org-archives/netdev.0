From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipv6: Fix tcp_v6_send_response checksum
Date: Wed, 21 Apr 2010 21:09:20 +0800
Message-ID: <20100421130920.GA31300@gondor.apana.org.au>
References: <20100421070737.GA30517@gondor.apana.org.au> <20100421.004922.193694715.davem@davemloft.net> <20100421.015823.266647388.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cratiu@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:38018 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754000Ab0DUNJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 09:09:25 -0400
Content-Disposition: inline
In-Reply-To: <20100421.015823.266647388.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 01:58:23AM -0700, David Miller wrote:
> 
> If we're going to use CHECKSUM_PARTIAL for these things (which we are
> since commit 2e8e18ef52e7dd1af0a3bd1f7d990a1d0b249586 "tcp: Set
> CHECKSUM_UNNECESSARY in tcp_init_nondata_skb"), we can't be setting
> buff->csum as we always have been here in tcp_v6_send_response.  We
> need to leave it at zero.
> 
> Kill that line and checksums are good again.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

That line is needed for the CHECKSUM_NONE case.  In fact, if we're
in the CHECKSUM_PARTIAL case, then that buff->csum calculation
should be a noop because it immediately gets overwritten when we
subsequently set csum_start/csum_offset.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
