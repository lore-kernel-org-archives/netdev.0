From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv6: Fix ip6_xmit to send fragments if ipfragok is true
Date: Thu, 31 Jul 2008 16:20:53 +0800
Message-ID: <20080731082053.GA6463@gondor.apana.org.au>
References: <489153ED.9030701@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56252 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751367AbYGaIVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 04:21:04 -0400
Content-Disposition: inline
In-Reply-To: <489153ED.9030701@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 01:55:57PM +0800, Wei Yongjun wrote:
> SCTP used ip6_xmit() to send fragments after received ICMP packet too
> big message. But while send packet used ip6_xmit, the skb->local_df is
> not initialized. So when skb if enter ip6_fragment
> <../cgi-bin/global.cgi?pattern=ip6_fragment&type=reference>(), the following
> code will discard the skb.

That sounds broken.  ip6_xmit is for TCP-like protocols that
perform PMTU-discovery.  Therefore it should never fragment
locally.

So either SCTP needs to do the same, or it should switch to
something other than ip6_xmit.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
