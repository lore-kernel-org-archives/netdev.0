From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: 2.6.29-rc5-git3 Leak r=1 3
Date: Fri, 27 Feb 2009 17:04:11 +0200
Message-ID: <200902271704.11449.denys@visp.net.lb>
References: <Pine.LNX.4.64.0902201805400.31742@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0902211324460.20284@wrl-59.cs.helsinki.fi> <20090221.235724.207966342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:55883 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396AbZB0PaP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 10:30:15 -0500
In-Reply-To: <20090221.235724.207966342.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 22 February 2009 09:57:24 David Miller wrote:
> From: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Sat, 21 Feb 2009 13:44:27 +0200 (EET)
>
> > [PATCH] tcp: fix retrans_out leaks in shifting code
> >
> > There's conflicting assumptions in shifting, the caller assumes
> > that dupsack results in S'ed skbs (or a part of it) for sure but
> > never gave a hint to tcp_sacktag_one when dsack is actually in
> > use. Thus DSACK retrans_out -=3D pcount was not taken and the
> > counter became out of sync. Remove obstacle from that information
> > flow to get DSACKs accounted in tcp_sacktag_one as expected.
> >
> > Compile tested only.
> >
> > In general the call to tcp_sacktag_one with the later full shift
> > from already SACKed skb should not be there, it's just doing
> > duplicating work already done earlier so it just wastes cycles and
> > also seems to duplicate small amount of code unnecessarily :-/.
> > However, moving tcp_sacktag_one call one level up is not what I wan=
t
> > to do in mainline -rc5, the counting & seqno state manipulation tha=
t
> > is going on there is just too hairy to get right in a hurry (order
> > is very significant there as the state transition is in progress
> > making normal invariants are not to be trusted). Luckily
> > tcp_sacktag_one is effectively a no-op atm with dup_sack set to 0
> > for already SACKed skb.
> >
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>
> Can you do some testing on this before I toss it into
> net-next-2.6? :-)  It looks fine to be, but... so did
> Herbert's URG change :)
Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>

No crashes for sure, running for 5 hours, no Leak messages appearing to=
o.
Test will continue more, after 20 hours more i can tell for sure, if it=
 helps=20
or not.

