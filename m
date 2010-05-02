From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: fix softnet_stat
Date: Sun, 02 May 2010 18:43:27 +0200
Message-ID: <1272818607.2173.133.camel@edumazet-laptop>
References: <1272814936-4902-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:56582 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757147Ab0EBQnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 12:43:32 -0400
Received: by bwz19 with SMTP id 19so916396bwz.21
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 09:43:30 -0700 (PDT)
In-Reply-To: <1272814936-4902-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 mai 2010 =C3=A0 23:42 +0800, Changli Gao a =C3=A9crit :
> fix softnet_stat
>=20
> Per cpu variable softnet_data.total was shared between IRQ and SoftIR=
Q context
> without any protection. And enqueue_to_backlog should update the netd=
ev_rx_stat
> of the target CPU.
>=20
> This patch renames softnet_data.total to softnet_data.processed: the =
number of
> packets processed in uppper levels(IP stacks).
>=20
> softnet_stat data is moved into softnet_data.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Thats a fine patch, thanks Changli.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>


> =20
> @@ -5869,6 +5866,7 @@ static int __init net_dev_init(void)
>  	for_each_possible_cpu(i) {
>  		struct softnet_data *sd =3D &per_cpu(softnet_data, i);
> =20
> +		memset(sd, 0, sizeof(*sd));
>  		skb_queue_head_init(&sd->input_pkt_queue);
>  		skb_queue_head_init(&sd->process_queue);
>  		sd->completion_queue =3D NULL;

Minor note :=20
- You could have removed some NULL initializations after the memset()
- Also, per_cpu data is already 0 initialized, so memset() is not
strictly needed ;)

This is very minor, since we dont have a bss section in per_cpu data, s=
o
it doesnt matter.



