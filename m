From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: Multicast packets being lost (3.10 stable)
Date: Tue, 25 Mar 2014 14:06:07 +0100
Message-ID: <20140325125231.GW6008@Linus-Debian>
References: <20140324094107.2cfbf103@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:61273 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751886AbaCYNGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2014 09:06:13 -0400
Content-Disposition: inline
In-Reply-To: <20140324094107.2cfbf103@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That commit is supposed to be a fix and seems to be a easily
cherry-pickable on top of 3.10. So I think it's suitable for
stable

There are two follow-up commit for this particular patch that I'm aware
of: "bridge: separate querier and query timer into IGMP/IPv4
and MLD/IPv6 ones" (cc0fdd80). That's just an optimization
and can be ignored for stable.

The second one is "bridge: don't try to update timers in case of
broken MLD queries" (248ba8ec0). Which is a direct fix for
b00589af3 and should therefore go into stable, too, if b00589af3
goes into stable.

Cheers, Linus


On Mon, Mar 24, 2014 at 09:41:07AM -0700, Stephen Hemminger wrote:
> We are seeing multicast snooping related issues.
> Is there some reason this commit never went into stable (3.10)
>=20
> commit b00589af3b04736376f24625ab0b394642e89e29
> Author: Linus L=C3=BCssing <linus.luessing@web.de>
> Date:   Thu Aug 1 01:06:20 2013 +0200
>=20
>     bridge: disable snooping if there is no querier
>    =20
>     If there is no querier on a link then we won't get periodic repor=
ts and
>     therefore won't be able to learn about multicast listeners behind=
 ports,
>     potentially leading to lost multicast packets, especially for mul=
ticast
>     listeners that joined before the creation of the bridge.
>    =20
>     These lost multicast packets can appear since c5c23260594
>     ("bridge: Add multicast_querier toggle and disable queries by def=
ault")
>     in particular.
>    =20
>     With this patch we are flooding multicast packets if our querier =
is
>     disabled and if we didn't detect any other querier.
>    =20
>     A grace period of the Maximum Response Delay of the querier is ad=
ded to
>     give multicast responses enough time to arrive and to be learned =
from
>     before disabling the flooding behaviour again.
>    =20
>     Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
