From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rps: fixed missed rps_unlock
Date: Mon, 05 Apr 2010 23:35:58 +0200
Message-ID: <1270503358.9013.38.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004051426140.22393@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:55877 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756396Ab0DEVgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 17:36:04 -0400
Received: by bwz1 with SMTP id 1so3120719bwz.21
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 14:36:02 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1004051426140.22393@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 avril 2010 =C3=A0 14:30 -0700, Tom Herbert a =C3=A9crit :
> Fix spin_unlock_irq which needs to be rps_unlock.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 2a9b7dd..74f77ca 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3120,7 +3120,7 @@ static int process_backlog(struct napi_struct *=
napi, int quota)
>  		skb =3D __skb_dequeue(&queue->input_pkt_queue);
>  		if (!skb) {
>  			__napi_complete(napi);
> -			spin_unlock_irq(&queue->input_pkt_queue.lock);
> +			rps_unlock(queue);
>  			break;
>  		}
>  		rps_unlock(queue);
> --

Yes, and rps_lock()/rps_unlock() are not well chosen either, but no
clever names come to my mind right now.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


