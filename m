From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Mon, 27 Sep 2010 07:40:01 +0200
Message-ID: <1285566001.2357.544.camel@edumazet-laptop>
References: <20100924063623.GA6359@ff.dom.local>
	 <1285311660.2380.62.camel@edumazet-laptop>
	 <20100926.182548.179922569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, xiaosuo@gmail.com, socketcan@hartkopp.net,
	mst@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55694 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872Ab0I0FkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 01:40:07 -0400
Received: by wwd20 with SMTP id 20so255607wwd.1
        for <netdev@vger.kernel.org>; Sun, 26 Sep 2010 22:40:05 -0700 (PDT)
In-Reply-To: <20100926.182548.179922569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 26 septembre 2010 =C3=A0 18:25 -0700, David Miller a =C3=A9=
crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 24 Sep 2010 09:01:00 +0200
>=20
> > af_packet (tx with mmap) is broken. I wonder who really uses it ?
>=20
> I suspect now that af_packet supports VNET headers on transmit,
> there are some things using this tx+mmap thing for sure.
>=20
> > To properly cope with paged skbs, it should not try to fit several
> > packets per page.
> >=20
> > The mmap api should change so that one mmaped page belongs to at mo=
st
> > one skb, or else we need invasive changes in net/core
> >=20
> > This probably makes this stuff less interesting, unless the need is=
 to
> > send big packets. In this case, why splice was not used instead of
> > custom mmap ?
>=20
> I don't really see what the big issue is.
>=20
> When the data destructor runs it means that packet's part of the page=
s
> are available for reuse for the tx mmap client.  And if I read it
> correctly, that's exactly what tpacket_destruct_skb() is in fact doin=
g.
>=20
> There seems to be no conflict with that rule and reusing a page for
> multiple packets.

I was wondering if somewhere we transfert a frag from one skb1 to
another skb2, and eventually free skb1.

I just check tcp collapse and found it was not coping with frags, yet.



