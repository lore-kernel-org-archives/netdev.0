From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Sun, 17 May 2009 15:31:27 -0700 (PDT)
Message-ID: <20090517.153127.22116458.davem@davemloft.net>
References: <Pine.LNX.4.64.0905111556300.10088@wrl-59.cs.helsinki.fi>
	<200905111554.50118.elendil@planet.nl>
	<Pine.LNX.4.64.0905111656450.10088@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: elendil@planet.nl, matthias.andree@gmx.de, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58483
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752445AbZEQWb3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2009 18:31:29 -0400
In-Reply-To: <Pine.LNX.4.64.0905111656450.10088@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 11 May 2009 17:57:13 +0300 (EEST)

> On Mon, 11 May 2009, Frans Pop wrote:
>=20
>> On Monday 11 May 2009, Ilpo J=E4rvinen wrote:
>> OK. I understood that there's always been a corner case with URG tha=
t=20
>> could cause incorrect messages [1] and I thought the additional chan=
ge=20
>> was to fix that, but if this is related to the same regression then =
of=20
>> course it's fine by me.
>>=20
>> [1] http://linux.derkeiler.com/Mailing-Lists/Kernel/2003-09/6009.htm=
l
>=20
> Ah, so there's some urg race for real... ...I didn't know about that
> which is no wonder since I've very little interest on knowing all
> corner cases of urg madness really :-).
>=20
> I guess it is not exactly the same though I have problem in understan=
ding=20
> what Dave is exactly meaning there but it could well be that there is=
n't=20
> a sane case where the urg hole thing matters for real. Well, Dave pro=
bably=20
> knows whether the v2 is necessary or not, I've no clue who is the one=
=20
> advancing the copied_seq (if it's not the gem in tcp_check_urg doing =
the=20
> conditional copied_seq++, but that condition is beyond my current lev=
el of=20
> concentration really).

The issue being discussed there is exactly the case where a thread
is triggering the copied_seq advance in tcp_check_urg() and using
MSG_PEEK at the same time.

I'm looking more closely into this patch right now, but I might ask
you to split the two fixes up if I can't convince myself %100 of the
URG part.  We've already broken URG enough lately :-)
