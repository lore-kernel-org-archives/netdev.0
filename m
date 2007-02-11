From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic: swapper/0x10000100/0
Date: Mon, 12 Feb 2007 09:53:00 +1100
Message-ID: <E1HGNZ6-0002j3-00@gondolin.me.apana.org.au>
References: <20070209223520.GA27634@electric-eye.fr.zoreil.com>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, lpiccilli@gelre.com.br,
	bugme-daemon@bugzilla.kernel.org
To: romieu@fr.zoreil.com (Francois Romieu)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2882 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932821AbXBKWx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Feb 2007 17:53:29 -0500
In-Reply-To: <20070209223520.GA27634@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> wrote:
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index e76539a..a4bcfe2 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -673,7 +673,7 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
>        struct sk_buff *skb;
>        int err = -ENOBUFS;
> 
> -       skb = nlmsg_new(if_nlmsg_size(0), GFP_KERNEL);
> +       skb = nlmsg_new(if_nlmsg_size(0), GFP_ATOMIC);
>        if (skb == NULL)
>                goto errout;

This should only be called under RTNL so it should never be atomic.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
