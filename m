From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about __alloc_skb() speedup
Date: Sat, 04 Dec 2010 15:47:38 +0100
Message-ID: <1291474058.2806.96.camel@edumazet-laptop>
References: <20101203101450.GA9573@Desktop-Junchang>
	 <1291373429.2897.96.camel@edumazet-laptop>
	 <20101204141826.GA5830@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49968 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754336Ab0LDOrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 09:47:43 -0500
Received: by wyb28 with SMTP id 28so10496022wyb.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 06:47:42 -0800 (PST)
In-Reply-To: <20101204141826.GA5830@Desktop-Junchang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 d=C3=A9cembre 2010 =C3=A0 22:18 +0800, Junchang Wang a =C3=
=A9crit :

> I added the prefetchw() in pktgen as follows:
>=20
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 2953b2a..512f1ae 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -2660,6 +2660,7 @@ static struct sk_buff *fill_packet_ipv4(struct =
net_device *odev,
>  		sprintf(pkt_dev->result, "No memory");
>  		return NULL;
>  	}
> +	prefetchw(skb->data);
> =20
>  	skb_reserve(skb, datalen);
> =20
> This time, I can check it without rebooting the system. The performan=
ce=20
> gain is 4%-5%(stable). Does 4% worth submitting it to the kernel?

Yes I believe so, pktgen being very specific, but I have few questions =
:

Is it with SLUB or SLAB ?

How many buffers in TX ring on you nic (ethtool -g eth0) ?

What is the datalen value here ? (you prefetch, then advance skb->data)

32 or 64bit kernel ?

How many pps do you get before and after patch ?

Thanks


