From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCHv5 1/5] [TCP]: Add highest_sack seqno, points to
 globally highest SACK
Date: Sun, 25 Mar 2007 18:35:22 -0700 (PDT)
Message-ID: <20070325.183522.15263841.davem@davemloft.net>
References: <11740704662337-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20070324.210428.78711276.davem@davemloft.net>
	<Pine.LNX.4.64.0703260034120.9398@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53390
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933328AbXCZBfX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2007 21:35:23 -0400
In-Reply-To: <Pine.LNX.4.64.0703260034120.9398@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 26 Mar 2007 00:55:57 +0300 (EEST)

> On Sat, 24 Mar 2007, David Miller wrote:
>=20
> > From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Fri, 16 Mar 2007 20:41:02 +0200
> >=20
> > > It is guaranteed to be valid only when !tp->sacked_out. In most
> > > cases this seqno is available in the last ACK but there is no
> > > guarantee for that. The new fast recovery loss marking algorithm
> > > needs this as entry point.
> >=20
> > It's a shame we keep around multiple values which represent very
> > related values.  For example, this new seqno could be computed
> > using "fackets_out" if we knew also how many holes there were.
>=20
> It would then be an estimate which is 100% accurate in most cases (wh=
en=20
> all related skbs are full sized). I think it must never underestimate=
=20
> highest_sack though, it would be quite ok to use fackets_out * mss bu=
t any=20
> > mss skb would obviously be a problem (if they ever occur)... Are al=
l=20
> paths ok with that (this is beoynd the codepaths I'm quite sure of...=
)?!

Right, I understand that we really can't even use such an estimate
because of the "full mss size" assumption.

In any event, maybe we can find another way to "integrate" other
values we maintain in tcp_sock we can be computed from other ones
cheaply.
