From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/4]: Store retransmit queue packets in RB tree.
Date: Wed, 28 Feb 2007 21:33:50 +0100
Message-ID: <45E5E72E.6070109@cosmosbay.com>
References: <20070228.114912.89063615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:36725 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbXB1UeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 15:34:08 -0500
In-Reply-To: <20070228.114912.89063615.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> commit c387760826bd71103220e06ca7b0bf90a785567e
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Tue Feb 27 16:44:42 2007 -0800
>=20
>     [TCP]: Store retransmit queue packets in RB tree.
>    =20
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 4ff3940..b70fd21 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -18,6 +18,7 @@
>  #include <linux/compiler.h>
>  #include <linux/time.h>
>  #include <linux/cache.h>
> +#include <linux/rbtree.h>
> =20
>  #include <asm/atomic.h>
>  #include <asm/types.h>
> @@ -232,6 +233,8 @@ struct sk_buff {
>  	struct sk_buff		*next;
>  	struct sk_buff		*prev;
> =20
> +	struct rb_node		rb;
> +
>  	struct sock		*sk;
>  	struct skb_timeval	tstamp;
>  	struct net_device	*dev;


I am not sure this rb_node placement is optimal. rb lookups want to acc=
ess=20
rb_node and end_seq. They should be placed in the same cache line :)

next/prev were at the begining of sk_buff, there is no such constraint =
for rb

