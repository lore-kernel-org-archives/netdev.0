From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] arp: flush arp cache on IFF_NOARP change
Date: Mon, 20 May 2013 13:46:33 -0700 (PDT)
Message-ID: <20130520.134633.448574202175922639.davem@davemloft.net>
References: <1369056541-4523-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758136Ab3ETUqe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:46:34 -0400
In-Reply-To: <1369056541-4523-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Mon, 20 May 2013 16:29:01 +0300

> IFF_NOARP affects what kind of neighbor entries are created
> (nud NOARP or nud INCOMPLETE). If the flag changes, flush the arp
> cache to refresh all entries.
>=20
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
> Cc: Patrick McHardy <kaber@trash.net>

This patch makes no sense at all.

The state bit in ->priv_flags is a boolean stating whether the
notified should do something or not.

But you're setting it to match what IFF_NOARP is.

You should set it any time IFF_NOARP _changes_, and then clear
the bit when the notifier clears the neighbour entries.
