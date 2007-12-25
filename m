From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Force TSO splits to MSS boundaries
Date: Mon, 24 Dec 2007 21:35:00 -0800 (PST)
Message-ID: <20071224.213500.193895301.davem@davemloft.net>
References: <20071220140012.GA22495@gondor.apana.org.au>
	<20071220.155518.42408378.davem@davemloft.net>
	<Pine.LNX.4.64.0712211953580.7301@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36433
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751051AbXLYFfB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Dec 2007 00:35:01 -0500
In-Reply-To: <Pine.LNX.4.64.0712211953580.7301@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 21 Dec 2007 20:55:28 +0200 (EET)

> [PATCH] [TCP]: Force TSO splits to MSS boundaries
>=20
> If snd_wnd - snd_nxt wasn't multiple of MSS, skb was split on
> odd boundary by the callers of tcp_window_allows.
>=20
> We try really hard to avoid unnecessary modulos. Therefore the
> old caller side check "if (skb->len < limit)" was too wide as
> well because limit is not bound in any way to skb->len and can
> cause spurious testing for trimming in the middle of the queue
> while we only wanted that to happen at the tail of the queue.
> A simple additional caller side check for tcp_write_queue_tail
> would likely have resulted 2 x modulos because the limit would
> have to be first calculated from window, however, doing that
> unnecessary modulo is not mandatory. After a minor change to
> the algorithm, simply determine first if the modulo is needed
> at all and at that point immediately decide also from which
> value it should be calculated from.
>=20
> This approach also kills some duplicated code.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Looks good, patch applied, thanks.

With respect to code duplicateion, tcp_push_one() is essentially
the inner loop of tcp_write_xmit() :-)
