From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH v2] netdev:bfin_mac: reclaim and free tx skb as soon as
	possible after transfer
Date: Thu, 3 Jun 2010 16:57:24 +0800
Message-ID: <AANLkTinrW2w9x6dbzTAzSrElqUueFOC6tJaPNsVcnLBv@mail.gmail.com>
References: <1275536881.18536.5.camel@eight.analog.com>
	<1275537919.29413.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sonic zhang <sonic.adi@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.211.179]:42592 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758470Ab0FCI51 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 04:57:27 -0400
Received: by ywh9 with SMTP id 9so6126762ywh.17
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 01:57:24 -0700 (PDT)
In-Reply-To: <1275537919.29413.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Jun 3, 2010 at 12:05 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Not related to your patch, but reviewing it I see this driver still d=
o
> the "dev->stats.tx_packets++; dev->stats.tx_bytes +=3D (skb->len);"
>
> This is not necessary and expensive, since we update txq stats in cor=
e
> network stack.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rc =3D ops->ndo_start_xmit(skb, dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (rc =3D=3D NETDEV_TX_OK)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0txq_trans_upda=
te(txq); =C2=A0<< here >>
>

Good suggestion for drivers. But I wonder whether there are stats for
received packets in core network stack.

I.e., can I replace "dev->stats.rx_packets++" and "dev->stats.rx_bytes
+=3D (skb->len);" with something already maintained by core stack? I
failed to find them.

Thanks.


--=20
--Junchang
