From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] xfrm: do not leak ESRCH to user space
Date: Tue, 28 Oct 2008 22:06:47 -0700 (PDT)
Message-ID: <20081028.220647.161635128.davem@davemloft.net>
References: <1224810300.8667.26.camel@sebastian.kern.oss.ntt.co.jp>
	<20081028.155817.216873568.davem@davemloft.net>
	<1225249103.7276.56.camel@sebastian.kern.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: fernando@oss.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45204
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751334AbYJ2FHJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 01:07:09 -0400
In-Reply-To: <1225249103.7276.56.camel@sebastian.kern.oss.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fernando Luis V=E1zquez Cao <fernando@oss.ntt.co.jp>
Date: Wed, 29 Oct 2008 11:58:23 +0900

> On Tue, 2008-10-28 at 15:58 -0700, David Miller wrote:
> > From: Fernando Luis V=E1zquez Cao <fernando@oss.ntt.co.jp>
> > Date: Fri, 24 Oct 2008 10:05:00 +0900
> >=20
> > > Looking at the code, the window during which an entry is in
> > > XFRM_STATE_EXPIRED state seems to be about 2 seconds in the worst=
 case.
> > > Connection attempts before and after that window would most likel=
y
> > > result in a successful connection or -EAGAIN, respectively. Would=
 not it
> > > make sense to return -EAGAIN also during that 2 seconds window?
> >=20
> > Only if an acquire has been triggered and is in progress, which as
> > explained above the code already seems to handle.
> As explained above that does not seem to be the case.
>=20
> Besides, there is also the case that km_query() in xfrm_state_find()
> fails in which we would leak -ESRCH to user space too. As mentioned i=
n a
> previous email, returning -EAGAIN is arguably more appropriate if the
> cause of km_query failing was that racoon's receive buffer was full
> (could happen under heavy load), because as racoon reads from it the
> problem will go away.

Good points, I'll think about this some more.

Thank you.
