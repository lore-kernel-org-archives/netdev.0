From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] netdev:bfin_mac: reclaim and free tx skb as soon as
  possible after transfer
Date: Thu, 03 Jun 2010 11:19:09 +0200
Message-ID: <1275556749.2456.24.camel@edumazet-laptop>
References: <1275536881.18536.5.camel@eight.analog.com>
	 <1275537919.29413.55.camel@edumazet-laptop>
	 <AANLkTinrW2w9x6dbzTAzSrElqUueFOC6tJaPNsVcnLBv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sonic zhang <sonic.adi@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37069 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933502Ab0FCJTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 05:19:13 -0400
Received: by fxm8 with SMTP id 8so2534811fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 02:19:12 -0700 (PDT)
In-Reply-To: <AANLkTinrW2w9x6dbzTAzSrElqUueFOC6tJaPNsVcnLBv@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 juin 2010 =C3=A0 16:57 +0800, Junchang Wang a =C3=A9crit :
> Hi Eric,
>=20
> On Thu, Jun 3, 2010 at 12:05 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Not related to your patch, but reviewing it I see this driver still=
 do
> > the "dev->stats.tx_packets++; dev->stats.tx_bytes +=3D (skb->len);"
> >
> > This is not necessary and expensive, since we update txq stats in c=
ore
> > network stack.
> >
> >        rc =3D ops->ndo_start_xmit(skb, dev);
> >        if (rc =3D=3D NETDEV_TX_OK)
> >                txq_trans_update(txq);  << here >>
> >
>=20
> Good suggestion for drivers. But I wonder whether there are stats for
> received packets in core network stack.
>=20

No its not there.

> I.e., can I replace "dev->stats.rx_packets++" and "dev->stats.rx_byte=
s
> +=3D (skb->len);" with something already maintained by core stack? I
> failed to find them.
>=20

As I said, core network takes care of three counters only, because it
was 'free', as they share a cache line with a spinlock we must hold whe=
n
calling xmit function.

In receive path, we dont dirty a cache line in core network, so updatin=
g
counters would add a cost. (modern NICs handle stats in firmware)



