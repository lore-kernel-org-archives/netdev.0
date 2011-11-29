From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: is non-inheritance of congestion control algorithm from the
 listen socket a bug or a feature?
Date: Tue, 29 Nov 2011 14:01:58 -0800
Message-ID: <20111129140158.352ea90b@nehalam.linuxnetplumber.net>
References: <1322600212.2596.13.camel@edumazet-laptop>
	<CAK6E8=djWDn=ZvD0XLxex3vOfsDjCT64k+DwDSNp6+tLbPen2A@mail.gmail.com>
	<1322603175.2596.31.camel@edumazet-laptop>
	<20111129.165205.91103035999089185.davem@davemloft.net>
	<1322603786.2596.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ycheng@google.com,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49776 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754298Ab1K2WCE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 17:02:04 -0500
In-Reply-To: <1322603786.2596.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Nov 2011 22:56:26 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mardi 29 novembre 2011 =E0 16:52 -0500, David Miller a =E9crit :
>=20
> > There is really no reason to keep the current behavior.
> >=20
> > If an application sets the congestion control algorithm on a listen=
ing
> > socket to a non-default value, what effect could possibly be intend=
ed?
> >=20
> > Congestion control doesn't even come into play at all on a listenin=
g
> > socket, therefore the only logical expectation is that it inherits =
to
> > the child.
> >=20
> > The only other logical behavior would be to forbid this operation o=
n a
> > listening socket, since it has no effect, but that doesn't make any
> > sense now does it? :-)
>=20
> Moreover, an application can use setsockopt(TCP_CONGESTION) before
> calling listen() (while socket is still in CLOSE state)

Agreed, it was just an oversight of the initial design.
The setsockopt() on the listening socket is ignored.
