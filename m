From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Tue, 24 Apr 2012 04:10:18 -0400 (EDT)
Message-ID: <20120424.041018.1514311596818654005.davem@davemloft.net>
References: <1335213446.5205.65.camel@edumazet-glaptop>
	<1335234012.5205.97.camel@edumazet-glaptop>
	<alpine.DEB.2.00.1204241026410.735@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, rick.jones2@hp.com, netdev@vger.kernel.org,
	therbert@google.com, ncardwell@google.com, maze@google.com,
	ycheng@google.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755823Ab2DXIKn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 04:10:43 -0400
In-Reply-To: <alpine.DEB.2.00.1204241026410.735@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 24 Apr 2012 11:01:37 +0300 (EEST)

> Why not, but wouldn't it be nicer to coalesce them already in GRO bel=
ow=20
> with an assumption that GRO is likely to find some "mss" equivivalent=
=20
> which tells the gap between consecutive ACK (or even SACK) seqnos?

GRO must be able to precisely reproduce the input stream if the packet
is forwarded and therefore we end up resegmenting on output with GSO.
That makes this a non-starter since we must therefore remember all of
the SACK boundaries in the original packets.
