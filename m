From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] tcp: collapse more than two on retransmission
Date: Mon, 24 Nov 2008 21:05:04 -0800 (PST)
Message-ID: <20081124.210504.30738317.davem@davemloft.net>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49384
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750793AbYKYFFF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 00:05:05 -0500
In-Reply-To: <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 24 Nov 2008 16:21:58 +0200

> I always had thought that collapsing up to two at a time was
> intentional decision to avoid excessive processing if 1 byte
> sized skbs are to be combined for a full mtu, and consecutive
> retransmissions would make the size of the retransmittee
> double each round anyway, but some recent discussion made me
> to understand that was not the case. Thus make collapse work
> more and wait less.
>=20
> It would be possible to take advantage of the shifting
> machinery (added in the later patch) in the case of paged
> data but that can be implemented on top of this change.

Yes, the ->nr_frags test is a real limiter these days
because on any modern device all TCP data is paged,
whether sendmsg() or sendpage() generated.

So you must have used a non-SG capable device for your
tests or simply turned SG off using ethtool :)

 ...
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks!
