From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ehea: Fixing statistics
Date: Tue, 26 Oct 2010 20:48:40 +0200
Message-ID: <1288118920.2652.4.camel@edumazet-laptop>
References: <1288116213-11801-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:63794 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379Ab0JZSsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 14:48:45 -0400
Received: by yxt33 with SMTP id 33so24888yxt.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 11:48:45 -0700 (PDT)
In-Reply-To: <1288116213-11801-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 14:03 -0400, leitao@linux.vnet.ibm.com =
a
=C3=A9crit :
> @@ -2296,6 +2314,7 @@ static int ehea_start_xmit(struct sk_buff *skb,=
 struct net_device *dev)
> =20
>  	ehea_post_swqe(pr->qp, swqe);
>  	pr->tx_packets++;
> +	pr->tx_bytes +=3D skb->len;
> =20
>  	if (unlikely(atomic_read(&pr->swqe_avail) <=3D 1)) {
>  		spin_lock_irqsave(&pr->netif_queue, flags);

This seems very suspicious to me. Lets take a look at this driver.

ehea_xmit3() frees the skb.

Yet, you happily use skb after it... kaboom...

Note: driver already uses skb after its freeing, before your patch.

        if (vlan_tx_tag_present(skb)) {
                swqe->tx_control |=3D EHEA_SWQE_VLAN_INSERT;
                swqe->vlan_tag =3D vlan_tx_tag_get(skb);
        }

How can it works ?



