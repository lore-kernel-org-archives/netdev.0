From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [PATCH] ipv4: fix ipsec forward performance regression
Date: Tue, 1 Nov 2011 18:50:22 -0500
Message-ID: <20111101185022.b156ea957baf286f1bf00f9c@freescale.com>
References: <4EA3C91C.3090801@intel.com>
	<1319360590.6180.75.camel@edumazet-laptop>
	<20111024.030203.404195331212003955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <eric.dumazet@gmail.com>, <zheng.z.yan@intel.com>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: <stable@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:53095
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932086Ab1KAXvU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Nov 2011 19:51:20 -0400
In-Reply-To: <20111024.030203.404195331212003955.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Oct 2011 03:02:03 -0400
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 23 Oct 2011 11:03:10 +0200
>=20
> > Le dimanche 23 octobre 2011 =E0 15:58 +0800, Yan, Zheng a =E9crit :
> >> There is bug in commit 5e2b61f(ipv4: Remove flowi from struct rtab=
le).
> >> It makes xfrm4_fill_dst() modify wrong data structure.
> >>=20
> >> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
>  ...
> > Reported-by: Kim Phillips <kim.phillips@freescale.com>
> >=20
> > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, thanks everyone.

To: <stable@kernel.org>

-stable maintainers, please consider the following two upstream
commits for inclusion in upcoming v3.0.x [1] stable releases:

v3.0.8 plus this:

upstream commit b73233960a59ee66e09d642f13d0592b13651e94
(ipv4: fix ipsec forward performance regression)

increases IPSec fwding performance from 0.2kpps to ~3.5kpps.

Adding this:

upstream commit aa1c366e4febc7f5c2b84958a2dd7cd70e28f9d0
(net: Handle different key sizes between address families in flow
cache)

to that, brings it back up to 2.6.38 levels, i.e., ~44kpps.

note that for v2.6.39.4 (.39 is the first kernel version with the
40->0.2kpps regression), commit b732339 depends on a slew of
commits, presumably ending with commit 5e2b61f: ipv4: Remove flowi
from struct rtable.

However it appears commit aa1c366e alone will restore almost all
the performance (~42kpps) on that kernel version.

So to summarize, please cherry-pick:

v2.6.39.x: aa1c366: net: Handle different key sizes between address fam=
ilies in flow cache
v3.0.x: aa1c366: net: Handle different key sizes between address famili=
es in flow cache
v3.0.x: b732339: ipv4: fix ipsec forward performance regression
v3.1.x: b732339: ipv4: fix ipsec forward performance regression

[All figures are based on a p2020ds board configured to rx, encrypt
and forward 64-byte packets.]

Thanks,

Kim

[1] initial kernel in long-term stable series for the embedded
industry (http://lwn.net/Articles/464834/)
