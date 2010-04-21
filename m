From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Wed, 21 Apr 2010 11:39:33 +0200
Message-ID: <1271842773.7895.1692.camel@edumazet-laptop>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Franco Fichtner <franco@lastsummer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:50387 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543Ab0DUJjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 05:39:42 -0400
Received: by bwz25 with SMTP id 25so7846272bwz.28
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 02:39:40 -0700 (PDT)
In-Reply-To: <4BCEC593.4000007@lastsummer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 avril 2010 =C3=A0 11:29 +0200, Franco Fichtner a =C3=A9c=
rit :
> Tom Herbert wrote:
> >> I thought about this for some time...
> >>
> >> Do we really need the port numbers here at all? A simple
> >> addr1^addr2 can provide a good enough pointer for
> >> distribution amongst CPUs.
> >>
> >=20
> > What about a server behind a TCP proxy?  Also, need to minimize
> > collisions for RPS to be effective
>=20
> What about routers? What about loopback? This all boils down to
> the same issue of obscuring IP data by "magical" means and then
> reattaching functionality by reaching for upper layer information.
> It is necessary in some cases, but it can cripple performance
> for other cases.
>=20
> The interesting thing is you don't need to deal with collisions
> while distributing amonst cpus at all. You just need to make sure
> the distribution algorithm keeps every single flow attached to
> the correct cpu.
>=20
> All of the actual flow hashing, tracking and whatever else the
> traffic needs to go through can be done locally by cpu x which
> helps a lot with load distribution and cache issues in mind. It
> also helps locking because there is no global flow lookup table.
> Oh, and it also reduces collisions with every cpu you add for
> receiving.
>=20
> I work with a lot of plain office and ISP traffic in mind daily,
> so please don't misunderstand my motivation here. I'd hate to
> see poor performance in scenarios in which there is a lot of
> potential improvement.
>=20

I am a bit lost by this conversation.

Are you saying something is wrong with current schem ?

What are exactly your suggestions ?

Tom replied to you that a hash derived from (addr1 ^ addr2) would not
work in situations where all flows goes from machine A to machine B
(all hashes would be the same)

Current hash is probably more than enough to cover all situations.





