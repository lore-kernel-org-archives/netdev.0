From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] ARC VMAC ethernet driver.
Date: Tue, 15 Feb 2011 11:02:29 +0100
Message-ID: <1297764149.3201.4.camel@edumazet-laptop>
References: <20101208.090040.39174008.davem@davemloft.net>
	 <1297762288-9263-1-git-send-email-afenkart@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andreas Fenkart <afenkart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:32947 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020Ab1BOKDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 05:03:32 -0500
Received: by fxm20 with SMTP id 20so6189528fxm.19
        for <netdev@vger.kernel.org>; Tue, 15 Feb 2011 02:03:31 -0800 (PST)
In-Reply-To: <1297762288-9263-1-git-send-email-afenkart@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 f=C3=A9vrier 2011 =C3=A0 10:31 +0100, Andreas Fenkart a =C3=
=A9crit :
> Signed-off-by: Andreas Fenkart <afenkart@gmail.com>


> +		processed++;
> +		skb->dev =3D dev;
	eth_type_trans() already sets "skb->dev =3D dev;"

> +		skb->protocol =3D eth_type_trans(skb, dev);
> +		ap->stats.rx_packets++;
Hmm, why dont you use dev->stats internal structure ? No need to
maintain a shadow in ap->stats.

> +		ap->stats.rx_bytes +=3D skb->len;
> +		dev->last_rx =3D jiffies;
	/* last_rx =3D jiffies; not needed anymore  */


> +		netif_rx(skb);

A NAPI driver should use netif_receive_skb(), not netif_rx()



