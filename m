From: David Miller <davem@davemloft.net>
Subject: Re: TSO trimming question
Date: Thu, 20 Dec 2007 04:00:37 -0800 (PST)
Message-ID: <20071220.040037.48002365.davem@davemloft.net>
References: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>
	<20071219.235450.170670042.davem@davemloft.net>
	<Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51626
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760419AbXLTMAh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 07:00:37 -0500
In-Reply-To: <Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 20 Dec 2007 13:40:51 +0200 (EET)

> That's not the only case, IMHO if there's odd boundary due to=20
> snd_una+snd_wnd - skb->seq limit (done in tcp_window_allows()), we do=
n't=20
> consider it as odd but break the skb at arbitary point resulting
> two small segments to the network, and what's worse, when the later s=
kb=20
> resulting from the first split is matching skb->len < limit check as =
well=20
> causing an unnecessary small skb to be created for nagle purpose too,=
=20
> solving it fully requires some thought in case the mss_now !=3D mss_c=
ache=20
> even if non-odd boundaries are honored in the middle of skb.

In the most ideal sense, tcp_window_allows() should probably
be changed to only return MSS multiples.

Unfortunately this would add an expensive modulo operation,
however I think it would elimiate this problem case.
