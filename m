From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] ipv6: Fix ip6_xmit to send fragments if ipfragok is
 true
Date: Thu, 31 Jul 2008 20:47:19 -0700 (PDT)
Message-ID: <20080731.204719.266390212.davem@davemloft.net>
References: <20080731092321.GA6907@gondor.apana.org.au>
	<48918C11.5010004@cn.fujitsu.com>
	<20080731104149.GA7601@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48104
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751969AbYHADrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 23:47:19 -0400
In-Reply-To: <20080731104149.GA7601@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 31 Jul 2008 18:41:50 +0800

> On Thu, Jul 31, 2008 at 05:55:29PM +0800, Wei Yongjun wrote:
> > SCTP used ip6_xmit() to send fragments after received ICMP packet too
> > big message. But while send packet used ip6_xmit, the skb->local_df is
> > not initialized. So when skb if enter ip6_fragment(), the following
> > code will discard the skb.
> > 
> > ip6_fragment(...)
> > {
> >    if (!skb->local_df) {
> >        ...
> >        return -EMSGSIZE;
> >    }
> >    ...
> > }
> > 
> > SCTP do the following step:
> > 1. send packet ip6_xmit(skb, ipfragok=0)
> > 2. received ICMP packet too big message
> > 3. if PMTUD_ENABLE: ip6_xmit(skb, ipfragok=1)
> > 
> > This patch fixed the problem by set local_df if ipfragok is true.
> > 
> > Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, and I'll queue this up for -stable.

Thanks everyone.
