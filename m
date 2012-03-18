From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] gianfar: Add support for byte queue limits.
Date: Sun, 18 Mar 2012 13:20:32 -0700
Message-ID: <1332102032.3722.53.camel@edumazet-laptop>
References: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
	 <1332089787-24086-2-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, therbert@google.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:37139 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359Ab2CRUUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 16:20:37 -0400
Received: by dajr28 with SMTP id r28so8861823daj.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 13:20:37 -0700 (PDT)
In-Reply-To: <1332089787-24086-2-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 mars 2012 =C3=A0 12:56 -0400, Paul Gortmaker a =C3=A9cri=
t :

=2E..

>  		 * we add this skb back into the pool, if it's the right size
> @@ -2557,13 +2568,15 @@ static int gfar_clean_tx_ring(struct gfar_pri=
v_tx_q *tx_queue)
>  	}
> =20
>  	/* If we freed a buffer, we can restart transmission, if necessary =
*/
> -	if (__netif_subqueue_stopped(dev, tx_queue->qindex) && tx_queue->nu=
m_txbdfree)
> -		netif_wake_subqueue(dev, tx_queue->qindex);
> +	if (__netif_subqueue_stopped(dev, tqi) && tx_queue->num_txbdfree)
> +		netif_wake_subqueue(dev, tqi);
> =20

You can use netif_tx_queue_stopped(txq) here instead of
__netif_subqueue_stopped(dev, tqi)=20

>  	/* Update dirty indicators */
>  	tx_queue->skb_dirtytx =3D skb_dirtytx;
>  	tx_queue->dirty_tx =3D bdp;
> =20
> +	netdev_tx_completed_queue(txq, howmany, bytes_sent);
> +
>  	return howmany;
>  }
> =20
