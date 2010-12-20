From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] net_sched: always clone skbs
Date: Tue, 21 Dec 2010 00:28:09 +0100
Message-ID: <1292887689.2627.150.camel@edumazet-laptop>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Pawel Staszewski <pstaszewski@itcare.pl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34310 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933143Ab0LTX2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 18:28:20 -0500
Received: by wwa36 with SMTP id 36so3561092wwa.1
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 15:28:19 -0800 (PST)
In-Reply-To: <20101220232020.GB2052@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 d=C3=A9cembre 2010 =C3=A0 00:20 +0100, Jarek Poplawski a =C3=
=A9crit :
> On Mon, Dec 20, 2010 at 10:35:30PM +0800, Changli Gao wrote:
> > Pawel reported a panic related to handling shared skbs in ixgbe
> > incorrectly. So we need to revert my previous patch to work around
> > this bug. Instead of reverting the patch completely, I just revert
> > the essential lines, so we can add the previous optimization
> > back more easily in future.
> >=20
> >     commit 3511c9132f8b1e1b5634e41a3331c44b0c13be70
> >     Author: Changli Gao <xiaosuo@gmail.com>
> >     Date:   Sat Oct 16 13:04:08 2010 +0000
> >    =20
> >         net_sched: remove the unused parameter of qdisc_create_dflt=
()
> >=20
>=20
> Isn't there some mistake in the commit number? IMHO this changelog is
> mostly wrong. The bug happens outside of ixgbe, probably in
> dev_hard_start_xmit() ->  __skb_linearize(), and even if not, it can,
> without any driver's fault. The only question is why it didn't triger
> with 2.6.36.
>=20

Indeed, commit number is wrong. It was :

commit 210d6de78c5d7c785fc532556cea340e517955e1
Author: Changli Gao <xiaosuo@gmail.com>
Date:   Thu Jun 24 16:25:12 2010 +0000

    act_mirred: don't clone skb when skb isn't shared

It triggers now because GRO might be default to on now.

commit 6a08d194ee40806e0ccd5f36ed768e64cbfc979f
e1000: use GRO for receive=20

(or other various GRO patches)



