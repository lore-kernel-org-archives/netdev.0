From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCHv5 4/5] [TCP]: new LOST marker optimizations
Date: Sat, 24 Mar 2007 21:10:50 -0700 (PDT)
Message-ID: <20070324.211050.106264545.davem@davemloft.net>
References: <11740704663404-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1174070466450-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11740704661086-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39867
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965010AbXCYEKv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2007 00:10:51 -0400
In-Reply-To: <11740704661086-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 16 Mar 2007 20:41:05 +0200

> 1) Couple of skb states are mutually exclusive
>=20
> Skb cannot be in both S and L states at the same time, adding
> non-S nor L skb count (below highest sack) to that can be
> compared against fackets_out to see if anything below the
> current skb can still be marked with L or not. If they're
> equal (or fackets_out is smaller), the next skb will have L
> set for sure.
>=20
> 2) Create a fastpath for the new LOST marker
>=20
> The fastpath takes advantage of the fact that the latest ACK
> very likely contains the globally highest SACK block. By
> verifying that is larger than tp->reordering, whole SACK block
> can be skipped while counting for not-to-be marked skbs until
> tp->reordering of them is encountered. Since TCP now can know,
> that should block exists as highest, the marking can begin right
> below it. If the latest ACK does not contain a SACK block that
> reaches all the way to the highest_sack (e.g., due to
> reordering), a slow path is used.

Excellent observation. :)

> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Patch applied, thanks.
