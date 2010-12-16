From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 15:41:58 +0100
Message-ID: <1292510518.2883.207.camel@edumazet-laptop>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
	 <AANLkTikdYi-Cs=4UtjJx-X4bW+LSKTQBTcSv23NS2S+S@mail.gmail.com>
	 <1292509118.2883.167.camel@edumazet-laptop>
	 <AANLkTimd96KoT1-KqeiF7i10pH3pfML=rsUho=cCancU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53983 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756167Ab0LPOmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 09:42:03 -0500
Received: by wyb28 with SMTP id 28so2568757wyb.19
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 06:42:02 -0800 (PST)
In-Reply-To: <AANLkTimd96KoT1-KqeiF7i10pH3pfML=rsUho=cCancU@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 22:31 +0800, Junchang Wang a =C3=A9=
crit :
> On Thu, Dec 16, 2010 at 10:18 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> >
> > Yes, and no.
> >
> > Consider the case you have one receiver.
> >
> > Packet given after Changli patch wont be shared, so packet_rcv wont
> > clone it : Thats a win. Only one skb_clone() done instead of two.
> >
> > Consider case with 2 receivers :
> >
> > First time we call packet_rcv, packet is shared (because we call
> > deliver_skb(), so packet_rcv clones it. Normal situation, we really=
 need
> > to clone it.
>=20
> Got it. Thanks.
>=20
> >
> > Second time, we give a non shared packet : Thats a win over previou=
s
> > situation.
> >
> But, if we have N receivers, we get only the last one win - the first=
 N-1 will
> call deliver_skb().
>=20

Yes, but you want to, because each receiver has to make a private copy
of the skb.

The big win is that if packet if filtered out (not accepted by the
socket filter), you end with no extra skb_clone() at all.

Say you have 8 receivers, with a filter matching some hash/cpu, and onl=
y
one af_packet socket will take the message.

Before patch : 8 skb_clones()

After patch : one skb_clone()

If I undertood patch intent ;)



