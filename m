From: Cedric Le Goater <legoater@free.fr>
Subject: Re: [PATCH net-2.6.24 0/3]: More TCP fixes
Date: Wed, 03 Oct 2007 14:48:43 +0200
Message-ID: <47038FAB.9020106@free.fr>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi> <470383D4.9060307@free.fr> <Pine.LNX.4.64.0710031503220.27745@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g19.free.fr ([212.27.42.36]:60104 "EHLO smtp6-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753534AbXJCMsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 08:48:46 -0400
In-Reply-To: <Pine.LNX.4.64.0710031503220.27745@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> On Wed, 3 Oct 2007, Cedric Le Goater wrote:
>=20
>> Ilpo J=E4rvinen wrote:
>>> Sacktag fastpath_cnt_hint seems to be very tricky to get right...
>>> I suppose this one fixes Cedric's case. I cannot say for sure   =20
>>> until there is something more definite indication of
>>> tcp_retrans_try_collapse origin than what the simple late WARN_ON
>>> gave for us. ...Especially since it's non-trivial to have skb
>>> hint "correctly" positioned in the write_queue while still ending
>>> up calling that function. However, considering how difficult it
>>> seems to be for Cedric to reproduce, it might well be this one.
>>>
>>> In addition, I noticed another reset which wasn't previously  =20
>>> converted to WARN_ON, so doing that now. Boot + simple xfer
>>> tested. Please apply to net-2.6.24.
>> I'm dropping the previous patches you sent me and switching to this =
patchset.=20
>> right ?
>=20
> Yes you can do that... However, there are two ways forward:
>=20
> 1) Drop and test with this patchset long enough to verify it's gone..=
=2E
> 2) No dropping and get the more exact trace by reproducing, which can=
=20
>    point out to tcp_retrans_try_collapse confirming the source of the
>    bug or revealing yet another bug...
>=20
> The first one has one drawback, it cannot prove the fix very well sin=
ce=20
> the bug could just not occur by chance... Path 2 would clearly show t=
he=20
> place from where the problem originates because we will know that it =
got=20
> triggered! I personally would prefer path 2 but whether you want to g=
o for=20
> that depends on the time you want to invest in it...
>=20
> ...I rediffed the tcp_verify_fackets patch too (below) just in case i=
t=20
> would be something else in you case and you choose path 1 (put it on =
top=20
> of this patchset, applies with some offsets). In case the problem is =
gone,=20
> it shouldn't trigger and if it does, we'll have another bug caught.

I have a spare node so I'm starting 2) with the 3 patches you sent and =
that
last one which applied fine. all of them on a fresh git pull of net-2.6=
=2E24

> Anyway, thanks for ccing right persons and netdev right from the=20
> beginning.

thanks to git ! :)=20

C.
=20

