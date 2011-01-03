From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] net_sched: mark packet staying on queue too long
Date: Mon, 03 Jan 2011 10:02:28 -0500
Message-ID: <1294066948.2472.49.camel@mojatatu>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
	 <1292887689.2627.150.camel@edumazet-laptop>
	 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
	 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	 <20101221223704.GA1979@del.dom.local> <1293111333.11306.170.camel@mojatatu>
	 <1294003631.2535.253.camel@edumazet-laptop>
	 <1294062755.2472.11.camel@mojatatu>
	 <1294063372.2892.408.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44102 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755205Ab1ACPDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 10:03:03 -0500
Received: by vws16 with SMTP id 16so5757278vws.19
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 07:03:01 -0800 (PST)
In-Reply-To: <1294063372.2892.408.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-03 at 15:02 +0100, Eric Dumazet wrote:
> Le lundi 03 janvier 2011 =C3=A0 08:52 -0500, jamal a =C3=A9crit :

> I got fairly good results here, but admit-idly on a LAN.

Maybe just adding the randomness marking factor alone may help.
It all depends on RTT.

> Yep, maybe adding RED on each SFQ slot ;) Should be fairly cheap, and
> actually needed in case ECN is not possible and we must earlly drop
> instead.
>=20

That would essentially be achieving the goal of SF Blue.

> I found BLUE very expensive in term of cache line accesses. Especiall=
y
> with double hashing.

If you can do it cheaply as you describe above, maybe should be
sufficient.

> local tcp, for a router ? Hmm... But yes I see your point.

Oh;-> thought you were talking host where my mumbling would make
more sense.

> Speaking of ECN marking, it seems we (in RED/GRED or tunnels) change =
skb
> data even if it is shared (can happen on ingress path)
>=20
> Probably harmless, but tcpdump can show ECN bit being marked even on =
skb
> snapshot before ingress (and later, ECN marked) or tunnels, while it
> came unset from the wire.
>=20
> Is it worth fixing this ? maybe using skb_make_writable() [once moved=
 to
> core network from netfilter]

Typically the netdev owns the packet once it gets to that level and
it can do whatever it wants with it. But if you are seeing it on
ingress (probably using ifb?), then it makes sense to fix it.

cheers,
jamal


