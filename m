From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv2] ipv6: Fix ip6_xmit to send fragments if ipfragok is true
Date: Thu, 31 Jul 2008 18:41:50 +0800
Message-ID: <20080731104149.GA7601@gondor.apana.org.au>
References: <489153ED.9030701@cn.fujitsu.com> <20080731082053.GA6463@gondor.apana.org.au> <489181DC.40507@cn.fujitsu.com> <20080731092321.GA6907@gondor.apana.org.au> <48918C11.5010004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35668 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751953AbYGaKl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:41:59 -0400
Content-Disposition: inline
In-Reply-To: <48918C11.5010004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 05:55:29PM +0800, Wei Yongjun wrote:
> SCTP used ip6_xmit() to send fragments after received ICMP packet too
> big message. But while send packet used ip6_xmit, the skb->local_df is
> not initialized. So when skb if enter ip6_fragment(), the following
> code will discard the skb.
> 
> ip6_fragment(...)
> {
>    if (!skb->local_df) {
>        ...
>        return -EMSGSIZE;
>    }
>    ...
> }
> 
> SCTP do the following step:
> 1. send packet ip6_xmit(skb, ipfragok=0)
> 2. received ICMP packet too big message
> 3. if PMTUD_ENABLE: ip6_xmit(skb, ipfragok=1)
> 
> This patch fixed the problem by set local_df if ipfragok is true.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
