From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Sun, 17 May 2009 15:41:37 -0700 (PDT)
Message-ID: <20090517.154137.104422195.davem@davemloft.net>
References: <Pine.LNX.4.64.0905070931590.12068@wrl-59.cs.helsinki.fi>
	<200905092014.35642.elendil@planet.nl>
	<Pine.LNX.4.64.0905110926520.10047@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: elendil@planet.nl, matthias.andree@gmx.de, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52393
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754491AbZEQWlk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2009 18:41:40 -0400
In-Reply-To: <Pine.LNX.4.64.0905110926520.10047@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 11 May 2009 09:32:34 +0300 (EEST)

> [PATCH v2] tcp: fix MSG_PEEK race check
>=20
> Commit 518a09ef11 (tcp: Fix recvmsg MSG_PEEK influence of
> blocking behavior) lets the loop run longer than the race check
> did previously expect, so we need to be more careful with this
> check and consider the work we have been doing.
>=20
> I tried my best to deal with urg hole madness too which happens
> here:
> 	if (!sock_flag(sk, SOCK_URGINLINE)) {
> 		++*seq;
> 		...
> by using additional offset by one but I certainly have very
> little interest in testing that part.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Tested-by: Frans Pop <elendil@planet.nl>

Ok, now that I've looked at this, the urg_hole part of this change has
to be removed.

That case being accounted for with urg_hole is exactly what the
debugging message is trying to catch, where we are doing MSG_PEEK and
tcp_check_urg() advances ->copied_seq on us during one of those
"release_sock();/lock_sock();" sequences (which thus invoke TCP input
processing).

Could you please respin this patch with the URG bits removed?

Thanks!
