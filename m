From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Subject: Re: [PATCH] net: l2tp_eth: fix max_mtu
Date: Thu, 20 Oct 2016 21:19:29 +0000
Message-ID: <1476998369.10048.1@x201s.roaming.asbjorn.biz>
References: <20161020200826.24578-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-/2Ytv3SIWkK+O8pVJQsL"
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:50114 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752872AbcJTVby (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 17:31:54 -0400
Cc: netdev@vger.kernel.org
Cc: Jarod Wilson <jarod@redhat.com>
Cc: R Parameswaran <parameswaran.r7@gmail.com>
In-Reply-To: <20161020200826.24578-1-asbjorn@asbjorn.st>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-/2Ytv3SIWkK+O8pVJQsL
Content-Type: text/plain; charset=UTF-8

On Thu, 20 Oct 2016 20:08:26 +0000 (UTC), ast@asbjorn.biz wrote:
> diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
> index 965f7e3..ba82dcc 100644
> --- a/net/l2tp/l2tp_eth.c
> +++ b/net/l2tp/l2tp_eth.c
> @@ -259,6 +259,7 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
>  		session->mtu = dev->mtu - session->hdr_len;
>  	dev->mtu = session->mtu;
>  	dev->needed_headroom += session->hdr_len;
> +	dev->max_mtu = ETH_MAX_MTU - dev->needed_headroom;

I forgot to add that subtracting dev->needed_headroom doesn't
give the exact maximum MTU, but one that is a bit too high.
It could also just be set to ETH_MAX_MTU, to indicate that
the encapsulation is not included.

Calculations like in R. Parameswaran's patch is needed for the
exact one.
https://lkml.org/lkml/2016/10/17/3

-- 
Best regards
Asbjørn Sloth Tønnesen

--=-/2Ytv3SIWkK+O8pVJQsL--
