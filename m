From: David Miller <davem@davemloft.net>
Subject: Re: net-next/unix: BUG: using smp_processor_id() in preemptible
Date: Mon, 24 Nov 2008 00:09:42 -0800 (PST)
Message-ID: <20081124.000942.193710927.davem@davemloft.net>
References: <20081123.172014.78676422.davem@davemloft.net>
	<20081123.173426.255648175.davem@davemloft.net>
	<492A5F6D.3040708@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33934
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750890AbYKXIJn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 03:09:43 -0500
In-Reply-To: <492A5F6D.3040708@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 24 Nov 2008 09:01:49 +0100

> David Miller a =E9crit :
> > From: David Miller <davem@davemloft.net>
> > Date: Sun, 23 Nov 2008 17:20:14 -0800 (PST)
> >=20
> >> From: Eric Dumazet <dada1@cosmosbay.com>
> >> Date: Sun, 23 Nov 2008 04:32:30 +0100
> >>
> >>> [PATCH] net: make sock_prot_inuse_add() preempt safe
> >  ...
> >> Eric, you added this bug by starting to use this interface in
> >> situations where BH's were not disabled.
> >>
> >> Ever existing use adhered to that rule.
> >>
> >> If you therefore want to call this interface in new locations,
> >> you have to make sure those locations follow the rule too.
> > Here is what I commited to fix this bug.
> > net: Make sure BHs are disabled in sock_prot_inuse_add()
> > The rule of calling sock_prot_inuse_add() is that BHs must
> > be disabled.  Some new calls were added where this was not
> > true and this tiggers warnings as reported by Ilpo.
> > Fix this by adding explicit BH disabling around those call sites.
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > ---
> >  net/netlink/af_netlink.c |    3 +++
> >  net/sctp/socket.c        |    4 ++++
> >  net/unix/af_unix.c       |    2 ++
> >  3 files changed, 9 insertions(+), 0 deletions(-)
>=20
> I believe some bits are missing
>=20
> Ilpo report was about unix_create1() being preemptable for example

Thanks for catching that oversight, applied.
