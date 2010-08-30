From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Mon, 30 Aug 2010 09:50:12 -0700 (PDT)
Message-ID: <20100830.095012.233695092.davem@davemloft.net>
References: <1283107162.2297.32.camel@edumazet-laptop>
	<20100830064231.GA7060@ff.dom.local>
	<20100830085721.54c8c31b@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39179
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755978Ab0H3Qt4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 12:49:56 -0400
In-Reply-To: <20100830085721.54c8c31b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 30 Aug 2010 08:57:21 -0700

> On Mon, 30 Aug 2010 06:42:31 +0000
> Jarek Poplawski <jarkao2@gmail.com> wrote:
>=20
>> On 2010-08-29 20:39, Eric Dumazet wrote:
>> > Le dimanche 29 ao=C3=BBt 2010 =C3  10:06 -0700, David Miller a =C3=
=A9crit :
>> >> From: Jarek Poplawski <jarkao2@gmail.com>
>> >> Date: Sun, 29 Aug 2010 11:59:51 +0200
>> >>
>> >>> Actually, when GRO compares napi->dev to skb->dev?
>> >>
>> >> Hmmm, I thought the code made a skb->dev comparison with the
>> >> existing SKBs in the list when checking for same-flow matches.
>> >>
>> >> It doesn't, probably based upon the assumption that a NAPI
>> >> instance maps to a unique device, the very topic we're
>> >> discussing right now :-/
>> >>
>> >>
>> >=20
>> > It does the check, Stephen added it in the commit I mentioned to s=
tart
>> > this thread.
>> >=20
>> > With net-next-2.6 this now reads :
>> >=20
>>=20
>> Since Stephen didn't seem to miss this too much it seems quite obvio=
us
>> to me this check should be removed.
>=20
> No. I just don't use that system much, breaking code for
> sake of one comparison is ridiculous.

It's not working to begin with.

I agree with Jarek that the check should be removed.  And GRO is one
of those places that, precisely, even one memory reference removal
can improve performance dramatically.

Herbert spent a lot of time doing micro-optimizations to make GRO
better and better, and the smallest things can turn out to make a huge
difference there.

