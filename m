From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: force a fresh timestamp for ingress
	packets
Date: Fri, 17 Dec 2010 08:34:13 +0000
Message-ID: <20101217083413.GB6907@ff.dom.local>
References: <1292428252.3427.342.camel@edumazet-laptop> <20101216211744.GA2191@del.dom.local> <1292535039.2655.13.camel@edumazet-laptop> <20101216220838.GB2191@del.dom.local> <1292538363.2655.20.camel@edumazet-laptop> <20101216224237.GC2191@del.dom.local> <1292542305.2655.25.camel@edumazet-laptop> <20101217073015.GA6907@ff.dom.local> <1292573297.2655.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:49801 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317Ab0LQIeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 03:34:20 -0500
Received: by fxm18 with SMTP id 18so409519fxm.2
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 00:34:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292573297.2655.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 17, 2010 at 09:08:17AM +0100, Eric Dumazet wrote:
> Le vendredi 17 d=E9cembre 2010 ?? 07:30 +0000, Jarek Poplawski a =E9c=
rit :
>=20
> > It is wrong because it brings back the inconsistency with ping etc.
> > described by Alex Sidorenko in the changelog of netem patch, but
> > use normal (not netem) ingress scheduling (ping results shouldn't
> > depend on sniffers).
>=20
> Care to explain why only netem should take care of this delaying
> problem ?
> If a packet is delayed on other qdisc, dont we have the same problem =
?

netem was treated as a special case just to pretend (lie) about the
net outside (still not depending on sniffers), but it's hard to
believe there are "normal" ping users after netem.

>=20
> Right now, ping lies, giving different results if a sniffer is active=
 or
> not.
>=20
> Care to suggest an alternative patch, because I am lost at this point=
 ?

Just what I wrote earlier: consider one additional cloning in
dev_queue_xmit_nit or maybe resetting the timestamp with act_skbedit?

Thanks,
Jarek P.
