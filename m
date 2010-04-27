From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] cxgb4: set skb->rxhash
Date: Wed, 28 Apr 2010 00:43:12 +0200
Message-ID: <1272408192.2343.32.camel@edumazet-laptop>
References: <1272406825-11615-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:59958 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757362Ab0D0WnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:43:17 -0400
Received: by bwz19 with SMTP id 19so80812bwz.21
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 15:43:15 -0700 (PDT)
In-Reply-To: <1272406825-11615-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 avril 2010 =C3=A0 15:20 -0700, Dimitris Michailidis a =C3=A9=
crit :
> Implement the ->set_flags ethtool method to control NETIF_F_RXHASH an=
d
> set skb->rxhash to the HW calculated hash accordingly.
>=20
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

>  	skb_record_rx_queue(skb, rxq->rspq.idx);
> +	if (rxq->rspq.netdev->features & NETIF_F_RXHASH)
> +		skb->rxhash =3D ntohl(pkt->rsshdr.hash_val);
> =20

Its probably minor, but hash_val being a semi random 32bits value, you
can avoid the ntohl() conversion, using a (__force u32) cast ...



