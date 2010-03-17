From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Wed, 17 Mar 2010 08:07:53 +0100
Message-ID: <1268809673.2932.62.camel@edumazet-laptop>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	 <4B9FC7F1.5010507@google.com> <1268773227.2932.34.camel@edumazet-laptop>
	 <20100316.141311.262178287.davem@davemloft.net>
	 <412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:54300 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658Ab0CQHH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 03:07:59 -0400
Received: by bwz3 with SMTP id 3so844785bwz.29
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 00:07:57 -0700 (PDT)
In-Reply-To: <412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 mars 2010 =C3=A0 09:54 +0800, Changli Gao a =C3=A9crit :
> On Wed, Mar 17, 2010 at 5:13 AM, David Miller <davem@davemloft.net> w=
rote:
> >
> > I'll integrate this as soon as I open up net-next-2.6
>=20
> It is really a good news. Now linux also can dispatch packets as
> FreeBSD does via netisr. Can we walk farer, and support weighted
> distribution?
>=20

May I ask why ? What would be the goal ?

If you perform too much work behalf the first cpu (the one actually
dealing with the device and dispatching packets to other cpus), you ris=
k
bringing into its cache whole packet and consuming too many cpu cycles.

=46or instance, I would prefer a basic spreading, and try to reorganise
sk_buffs to that this cpu touches only one cache line in sk_buff, and
read one cache line in packet data to compute rxhash.

Then some NIC could compute rxhash themselves and provide it in their
rx_desc. Of course multiqueue support is much better and current
hardware prefer to implement the real thing.



