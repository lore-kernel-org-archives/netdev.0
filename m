From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 09 Sep 2008 22:23:30 -0700 (PDT)
Message-ID: <20080909.222330.172681301.davem@davemloft.net>
References: <20080910040107.GA29695@gondor.apana.org.au>
	<20080909.210654.159776216.davem@davemloft.net>
	<48C7581C.1080800@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57374
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751209AbYIJFXh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2008 01:23:37 -0400
In-Reply-To: <48C7581C.1080800@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed, 10 Sep 2008 08:16:12 +0300

> David Miller wrote:
> > ipsec: Restore hash based xfrm_state dumping.
> >=20
> > Get rid of ->all member of struct xfrm_state, and just use a hash
> > iteration like we used before.
> >=20
> > This shrinks the size of struct xfrm_state, and also restores the
> > dump ordering of 2.6.25 and previous.
>=20
> I think bad things will happen if the hash gets resized between
> xfrm_state_walk() calls. Since it assumes that the walk->state
> entry has remained in walk->chain bucket.
>=20
> The dumping order shouldn't really make any difference. But
> reducing struct xfrm_state is definitely good. The only downside
> is that when an entry is inserted to the beginning of the hash
> while dump is ongoing, it won't be dumped at all. But that is
> not really a problem since you get a notification about that
> entry separately.

That's a good point, the hash resizing case.

If the hash grows, we'll see some entries again.

If it shrinks, we might skip some instead, which is very undesirable.

Actually, thinking about it some more, both possibilities (skipping
and dups) seem to be possible in both situations (growing and
shrinking).

Ehm... I think we should put this patch and idea aside for a little bit=
=2E
:-)
