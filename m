From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 25 Dec 2008 17:11:46 -0800 (PST)
Message-ID: <20081225.171146.208898156.davem@davemloft.net>
References: <20081217212907.GA27243@gondor.apana.org.au>
	<20081217225231.GA28052@gondor.apana.org.au>
	<Pine.LNX.4.64.0812182040120.11995@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	ptesarik@suse.cz, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60265
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752154AbYLZBLn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Dec 2008 20:11:43 -0500
In-Reply-To: <Pine.LNX.4.64.0812182040120.11995@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 18 Dec 2008 21:45:13 +0200 (EET)

> No, would you use that 0xffff hack with gso you would create even wor=
se=20
> problem in case of reordering / losses. And that's just because the v=
ery=20
> scenario still remains fully unsolved. I'm not sure if you understood=
 my=20
> scenario at all (I was hopeful that you did :-))? It's basically that=
=20
> (with the terms of this hack) some segments in a super-skb would need=
 to=20
> set 0xffff while some < 0xffff. ...But you just can't send too large =
urg=20
> ptr in any segment or you're asking for trouble.

Hmmm, since URG is relative it means that GSO (or in-hardware TSO)
would need to adjust the URG offset for each segment.

But if we stick this 0xffff thing there, it _can't_ do that properly
because it cannot know where the correct URG pointer actually is.

In fact, the straightforward URG offset adjust one would expect a TSO
engine to make would corrupt the URG pointer when we put this
"infinity" value there.

The URG pointer might be >=3D 0xffff from the initial sequence number
of the starting TSO segment, but the URG offset might be in range
of one of the non-initial MSS segmented frames.

Anyways, we skip TSO/GSO for any time URG is indicated making all of
this particular concern moot. ;-)  But if at some point we want to
allow it, we'd need to consider this problem.


