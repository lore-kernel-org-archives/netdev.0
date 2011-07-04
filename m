From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Mon, 04 Jul 2011 16:00:49 +0200
Message-ID: <1309788049.2247.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	 <20110629145135.5179fb0c.akpm@linux-foundation.org>
	 <BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	 <CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
	 <1309707971.2523.20.camel@edumazet-laptop>
	 <CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45380 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845Ab1GDOBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 10:01:05 -0400
Received: by wwe5 with SMTP id 5so5109463wwe.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 07:01:03 -0700 (PDT)
In-Reply-To: <CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 juillet 2011 =C3=A0 15:48 +0400, Alexey Zaytsev a =C3=A9cri=
t :

>=20
> This might fix a potential problem, but unfortunately did not help he=
re.
>=20
> There is an other place that looks suspicious to me:
>=20
>  812                         struct sk_buff *copy_skb;
>  813
>  814                         b44_recycle_rx(bp, cons, bp->rx_prod);
>  815                         copy_skb =3D netdev_alloc_skb(bp->dev, l=
en + 2);
>  816                         if (copy_skb =3D=3D NULL)
>  817                                 goto drop_it_no_recycle;
>  818
>  819                         skb_reserve(copy_skb, 2);
>  820                         skb_put(copy_skb, len);
>  821                         /* DMA sync done above, copy just the
> actual packet */
>  822                         skb_copy_from_linear_data_offset(skb,
> RX_PKT_OFFSET,
>  823
> copy_skb->data, len);
>  824                         skb =3D copy_skb;
>=20
>=20
> The skb is reinserted into the ring before its data is copied, it
> seems. But this can't be the cause of my problem, as it would lead to
> data corruption at most, not a write-after-free.
>=20
> And an other question. Why so we have the logic to work-around the 1G=
b
> DMA limit instead of just setting the dma mask?

Your problem is in RX side : NIC actually writes to a buffer that is
supposedly not its property.

If DMA workaround is triggered, all frames are copied, so bug has no
chance to trigger, because we feed a totally new frame to upper stack,
and keep reuse 'DMA' frames for the device itself.




