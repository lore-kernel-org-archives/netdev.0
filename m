From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Mon, 18 May 2009 21:40:39 -0700 (PDT)
Message-ID: <20090518.214039.143926575.davem@davemloft.net>
References: <Pine.LNX.4.64.0905180958150.3381@wrl-59.cs.helsinki.fi>
	<20090518.150433.92463181.davem@davemloft.net>
	<Pine.LNX.4.64.0905190654400.4379@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: elendil@planet.nl, matthias.andree@gmx.de, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33651
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750840AbZESEkl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 00:40:41 -0400
In-Reply-To: <Pine.LNX.4.64.0905190654400.4379@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 19 May 2009 07:33:02 +0300 (EEST)

> Sure, the copied_seq is moving, but what I'm after is that does it re=
ally=20
> make any difference from tcp_recvmsg point of view? It certainly trig=
gers=20
> the message but that won't work as a proof of the evilness for me.
>=20
> ...The above paragraph is assuming recvmsg is able to deal with that =
and=20
> doesn't choke because of the changing copied_seq. I'd have to audit i=
t=20
> once again to verify that it's really ok but I don't see any particul=
ar=20
> reason why it couldn't be possible to make recvmsg to not care on the=
=20
> tcp_check_urg side copied_seq changes but I'd like to hear a clear=20
> confirmation on that from you too.

recvmsg can deal with it fine, because we reset the peek_seq when we
print out that message.

There is no way that an application writer has any clue about this
interaction, where peeked bytes disappear and then reappear in
the out-of-band URG byte.  That's why the message is there.
