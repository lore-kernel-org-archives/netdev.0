From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Wed, 21 Apr 2010 13:16:28 +0200
Message-ID: <1271848589.7895.1896.camel@edumazet-laptop>
References: <1271452358.16881.4486.camel@edumazet-laptop>
	 <1271520633.16881.4754.camel@edumazet-laptop>
	 <20100419.130905.210660275.davem@davemloft.net>
	 <20100419.132318.192086187.davem@davemloft.net>
	 <1271709121.3845.94.camel@edumazet-laptop>
	 <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>
	 <1271743164.3845.128.camel@edumazet-laptop>
	 <1271750198.3845.216.camel@edumazet-laptop>
	 <4BCDA2B5.4060609@lastsummer.de>
	 <i2q65634d661004200809ydba56c35g785ba51900c379f7@mail.gmail.com>
	 <4BCEC593.4000007@lastsummer.de>
	 <1271842773.7895.1692.camel@edumazet-laptop>
	 <4BCEDC29.6040303@lastsummer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Franco Fichtner <franco@lastsummer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:52089 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab0DULQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 07:16:38 -0400
Received: by bwz25 with SMTP id 25so7968507bwz.28
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 04:16:36 -0700 (PDT)
In-Reply-To: <4BCEDC29.6040303@lastsummer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 avril 2010 =C3=A0 13:06 +0200, Franco Fichtner a =C3=A9c=
rit :
> >=20
>=20
> Hashing for cpu distribution should be as minimal as it could possibl=
y
> be with the least number operations needed to compute a hash, which=20
> normally involves touching one cold cache line (ip header). If you ad=
d=20
> the ports to your mix you have the luxury of solving static ip mappin=
gs,
> but only for protocols that support it. Usage of the destination port
> may also prove to be more or less pointless with a lot of http traffi=
c,
> because it's most likely static. And you add another potential cold
> cache line access. For a lot of traffic scenarios, we'll have a bunch=
 of
> internal ips and the internet on the other side, so having a simple h=
ash
> based on a flavor if internal/external ip is more than enough to work
> with for distribution. If the network card can provide a complete has=
h
> all the better. Then this part of my point is void.
>=20

But we already have to bring into our cpu cache one cache line, needed
in eth_type_trans() : (12+2 bytes of ethernet header)

TCP/UDP tuples are included into this cache line (64 bytes on current
popular arches)

Cost of rxhash is absolute noise into the picture.
A device provided hash, to be effective, would also make
eth_type_trans() call not done.



