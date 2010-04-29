From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Thu, 29 Apr 2010 06:09:36 +0200
Message-ID: <1272514176.2201.85.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272018366.7895.7930.camel@edumazet-laptop>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:57974 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934277Ab0D3T1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 15:27:22 -0400
Received: by bwz19 with SMTP id 19so330664bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 12:27:17 -0700 (PDT)
In-Reply-To: <1272498293.4258.121.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 28 avril 2010 =C3=A0 19:44 -0400, jamal a =C3=A9crit :
> On Wed, 2010-04-28 at 16:06 +0200, Eric Dumazet wrote:
>=20
> > Here it is ;)
>=20
> Sorry - things got a little hectic with TheMan.
>=20
> I am afraid i dont have good news.
> Actually, I should say i dont have good news in regards to rps.
> For my sample app, two things seem to be happening:
> a) The overall performance has gotten better for both rps
> and non-rps.
> b) non-rps is now performing relatively better
>=20
> This is just what i see in net-next not related to your patch.
> It seems the kernels i tested prior to April 23 showed rps better.
> The one i tested on Apr23 showed rps being about the same as non-rps.
> As i stated in my last result posting, I thought i didnt test properl=
y
> but i did again today and saw the same thing. And now non-rps is
> _consistently_ better.
> So some regression is going on...
>=20
> Your patch has improved the performance of rps relative to what is in
> net-next very lightly; but it has also improved the performance of
> non-rps;->
> My traces look different for the app cpu than yours - likely because =
of
> the apps being different.
>=20
> At the moment i dont have time to dig deeper into code, but i could
> test as cycles show up.
>=20
> I am attaching the profile traces and results.
>=20
> cheers,
> jamal

Hi Jamal

I dont see in your results the number of pps, number of udp ports,
number of flows.

In my latest results, I can handle more pps than before, regardless of
rps being on or off, and with various number of udp ports (one user
thread per port), number of flows (many src addr so that rps spread
packets on many cpus)

If/when contention windows are smaller, cpu can run uncontended, and ca=
n
consume more cycles to process more frames ?

With a non yet published patch, I even can reach 600.000 pps in DDOS
situations, instead of 400.000.

Thanks !


