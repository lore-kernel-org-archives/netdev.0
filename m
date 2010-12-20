From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] net_sched: always clone skbs
Date: Tue, 21 Dec 2010 00:52:09 +0100
Message-ID: <20101220235209.GA1865@del.dom.local>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
 <20101220232020.GB2052@del.dom.local>
 <1292887689.2627.150.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Pawel Staszewski <pstaszewski@itcare.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:44856 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933313Ab0LTXwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 18:52:15 -0500
Received: by mail-bw0-f45.google.com with SMTP id 16so3941636bwz.4
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 15:52:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292887689.2627.150.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 21, 2010 at 12:28:09AM +0100, Eric Dumazet wrote:
> Le mardi 21 d=E9cembre 2010 ?? 00:20 +0100, Jarek Poplawski a =E9crit=
 :
> > On Mon, Dec 20, 2010 at 10:35:30PM +0800, Changli Gao wrote:
> > > Pawel reported a panic related to handling shared skbs in ixgbe
> > > incorrectly. So we need to revert my previous patch to work aroun=
d
> > > this bug. Instead of reverting the patch completely, I just rever=
t
> > > the essential lines, so we can add the previous optimization
> > > back more easily in future.
> > >=20
> > >     commit 3511c9132f8b1e1b5634e41a3331c44b0c13be70
> > >     Author: Changli Gao <xiaosuo@gmail.com>
> > >     Date:   Sat Oct 16 13:04:08 2010 +0000
> > >    =20
> > >         net_sched: remove the unused parameter of qdisc_create_df=
lt()
> > >=20
> >=20
> > Isn't there some mistake in the commit number? IMHO this changelog =
is
> > mostly wrong. The bug happens outside of ixgbe, probably in
> > dev_hard_start_xmit() ->  __skb_linearize(), and even if not, it ca=
n,
> > without any driver's fault. The only question is why it didn't trig=
er
> > with 2.6.36.
> >=20
>=20
> Indeed, commit number is wrong. It was :
>=20
> commit 210d6de78c5d7c785fc532556cea340e517955e1
> Author: Changli Gao <xiaosuo@gmail.com>
> Date:   Thu Jun 24 16:25:12 2010 +0000
>=20
>     act_mirred: don't clone skb when skb isn't shared
>=20
> It triggers now because GRO might be default to on now.
>=20
> commit 6a08d194ee40806e0ccd5f36ed768e64cbfc979f
> e1000: use GRO for receive=20
>=20
> (or other various GRO patches)

Well, still some doubt after re-reading Pawel's 1st. message:

host1 (kernel 2.6.36.2)
netperf client -> eth3 (82598EB 10-Gigabit AT CX4) - directly connected=
 to eth2 of host2
ethtool -k eth3
Offload parameters for eth3:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on=20
=2E..

Of course, I know this was another box.

Jarek P.
