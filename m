From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Fri, 01 Aug 2008 17:11:01 +0800
Message-ID: <E1KOqf7-0004lB-00@gondolin.me.apana.org.au>
References: <48929C5B.5030108@cn.fujitsu.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com (Wei Yongjun)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50208 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751863AbYHAJLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 05:11:09 -0400
In-Reply-To: <48929C5B.5030108@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun <yjwei@cn.fujitsu.com> wrote:
>
> inet6_csk_xmit() just be used by tcp and dccp:
> 1042 net/dccp/ipv6.c      .queue_xmit       = inet6_csk_xmit
> 1853 net/ipv6/tcp_ipv6.c     .queue_xmit       = inet6_csk_xmit,
> 
> And used always with ipfragok = 0.
> 139 net/dccp/output.c         err = icsk->icsk_af_ops->queue_xmit(skb, 0);
> 626 net/ipv4/tcp_output.c     err = icsk->icsk_af_ops->queue_xmit(skb, 0);
> 
> I can not find any place used inet6_csk_xmit() with ipfragok = 1.
> 
> So I think it is safe to apply this patch. Or maybe this paramater is 
> useless.

No we should get rid of the ipfragok argument if noone uses it.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
