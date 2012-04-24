From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Tue, 24 Apr 2012 10:56:43 +0200
Message-ID: <1335257803.5205.133.camel@edumazet-glaptop>
References: <alpine.DEB.2.00.1204241026410.735@wel-95.cs.helsinki.fi>
	 <20120424.041018.1514311596818654005.davem@davemloft.net>
	 <alpine.DEB.2.00.1204241113020.735@wel-95.cs.helsinki.fi>
	 <20120424.042546.2154907239944513463.davem@davemloft.net>
	 <alpine.DEB.2.00.1204241131580.735@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	Netdev <netdev@vger.kernel.org>, therbert@google.com,
	ncardwell@google.com, maze@google.com,
	Yuchung Cheng <ycheng@google.com>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34068 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452Ab2DXI4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 04:56:48 -0400
Received: by bkuw12 with SMTP id w12so221651bku.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 01:56:47 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1204241131580.735@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-24 at 11:40 +0300, Ilpo J=C3=A4rvinen wrote:

> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 8bb6ade..33b87b2 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2820,7 +2820,11 @@ found:
>  	flush |=3D (__force int)(flags & TCP_FLAG_CWR);
>  	flush |=3D (__force int)((flags ^ tcp_flag_word(th2)) &
>  		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH));
> -	flush |=3D (__force int)(th->ack_seq ^ th2->ack_seq);
> +
> +	ackgap =3D skb_shinfo(p)->ack_size;
> +	ackdiff =3D th2->ack_seq - th->ack_seq;
> +	flush |=3D (ackdiff - 1) >=3D ackgap;
> +
>  	for (i =3D sizeof(*th); i < thlen; i +=3D 4)
>  		flush |=3D *(u32 *)((u8 *)th + i) ^
>  			 *(u32 *)((u8 *)th2 + i);
>=20

See how we duplicate tcp stack in GRO layer ;)

Really I have many doubts about GRO today.
