From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2 9/9] sfc: Support for byte queue limits
Date: Tue, 09 Aug 2011 10:21:47 +0200
Message-ID: <1312878107.2371.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1108072151500.13386@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39391 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483Ab1HIIVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 04:21:50 -0400
Received: by wyg24 with SMTP id 24so182913wyg.19
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 01:21:48 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1108072151500.13386@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 07 ao=C3=BBt 2011 =C3=A0 21:53 -0700, Tom Herbert a =C3=A9c=
rit :
> Changes to sfc to use byte queue limits.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---


>  void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
> @@ -1168,6 +1181,8 @@ static int efx_enqueue_skb_tso(struct efx_tx_qu=
eue *tx_queue,
>  	/* Pass off to hardware */
>  	efx_nic_push_buffers(tx_queue);
> =20
> +	netdev_tx_sent_queue(tx_queue->core_txq, 1, skb->len);
> +
>  	tx_queue->tso_bursts++;
>  	return NETDEV_TX_OK;
> =20

Hmm, thats too late at this point : Hardware might have sent the buffer
and tx completion already freed skb.



