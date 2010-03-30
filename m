From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH] gianfar: Fix a memory leak in gianfar close code
Date: Tue, 30 Mar 2010 09:50:49 -0700
Message-ID: <j2t97949e3e1003300950rce90ebd0r77ecf1386eaeb4c4@mail.gmail.com>
References: <1269913343-6566-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, Sandeep.Kumar@freescale.com
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:13958 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826Ab0C3QvV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 12:51:21 -0400
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o2UGpA6C020516
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 18:51:11 +0200
Received: from gyd10 (gyd10.prod.google.com [10.243.49.202])
	by kpbe15.cbf.corp.google.com with ESMTP id o2UGoSMx005926
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 09:51:09 -0700
Received: by gyd10 with SMTP id 10so6441872gyd.38
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 09:51:09 -0700 (PDT)
In-Reply-To: <1269913343-6566-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

since free_skb_[rx | tx]_queue() expects rx_queue->rx_skbuff to not be =
NULL
what about moving the conditional if(rx_queue->rx_skbuff)
in free_skb_rx_queue() and  if(tx_queue->tx_skbuff) in free_skb_tx_queu=
e()
OR put an assertion for not NULL in those functions ?



On Mon, Mar 29, 2010 at 6:42 PM, Andy Fleming <afleming@freescale.com> =
wrote:
> gianfar needed to ensure existence of the *skbuff arrays before
> freeing the skbs in them, rather than ensuring their nonexistence.
>
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
> =A0drivers/net/gianfar.c | =A0 =A04 ++--
> =A01 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index b671555..ad59608 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -1638,13 +1638,13 @@ static void free_skb_resources(struct gfar_pr=
ivate *priv)
> =A0 =A0 =A0 =A0/* Go through all the buffer descriptors and free thei=
r data buffers */
> =A0 =A0 =A0 =A0for (i =3D 0; i < priv->num_tx_queues; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tx_queue =3D priv->tx_queue[i];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if(!tx_queue->tx_skbuff)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if(tx_queue->tx_skbuff)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_skb_tx_queue(tx_q=
ueue);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < priv->num_rx_queues; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_queue =3D priv->rx_queue[i];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if(!rx_queue->rx_skbuff)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if(rx_queue->rx_skbuff)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_skb_rx_queue(rx_q=
ueue);
> =A0 =A0 =A0 =A0}
>
> --
> 1.6.5.2.g6ff9a
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
