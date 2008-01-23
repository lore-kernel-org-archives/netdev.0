From: David Miller <davem@davemloft.net>
Subject: Re: Assertions in latest kernels
Date: Wed, 23 Jan 2008 03:06:35 -0800 (PST)
Message-ID: <20080123.030635.120969250.davem@davemloft.net>
References: <OF6C895B68.E4A75EFD-ON652573D9.0034E821-652573D9.0034BF2E@in.ibm.com>
	<Pine.LNX.4.64.0801231140120.31652@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0801231215250.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52006
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750967AbYAWLG0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 06:06:26 -0500
In-Reply-To: <Pine.LNX.4.64.0801231215250.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 23 Jan 2008 12:49:31 +0200 (EET)

> On Wed, 23 Jan 2008, Ilpo J=E4rvinen wrote:
>=20
> Hmm, perhaps it could be something related to this (and some untested=
=20
> path somewhere which is now exposed):
>=20
> commit 4a55b553f691abadaa63570dfc714e20913561c1
> Author: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Date:   Thu Dec 20 20:36:03 2007 -0800
>=20
>     [TCP]: Fix TSO deferring
>=20
> Dave, what do you think? Wouldn't explain the one -rc only report tho=
ugh=20
> from Denys. Another one I'm a bit unsure of is this:

Right, this would be something to consider for the net-2.6.25
and thus -mm cases, but not for 2.6.24* since this patch didn't
go there.

I don't see how this change could matter offhand.  Even with that
incorrect TSO test, the same set of write queue configurations can
still occur just some less likely than after the patch.

I would expect the usual global test coverage to narrow that gap.

> commit 757c32944b80fd95542bd66f06032ab773034d53
> Author: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Date:   Thu Jan 3 20:39:01 2008 -0800
>=20
>     [TCP]: Perform setting of common control fields in one place
>=20
> ->sacked field is cleared in tcp_retransmit_skb due to a subtle chang=
e,=20
> which might be buggy.... However, I find it rather unlikely that this=
=20
> would explain Kumar's case. Anyway, here's the one that reverts the=20
> problematic part of it. ...and this is net-2.6.25 as well so it won't=
=20
> solve Denys' case either.

I also suspect this one isn't the cause.

I think we'll be better off once we get some more data,
and therefore be able to make more correlations between
the various failures.

Anyways your patch here is a good start as it will provable
eliminate this as a possibility.
