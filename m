From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6: Bug in net-next
Date: Wed, 8 Jan 2014 15:04:00 +0100
Message-ID: <20140108140400.GH9007@order.stressinduktion.org>
References: <1389187126.20074.YahooMailBasic@web125504.mail.ne1.yahoo.com> <1389188139.44648.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48311 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756221AbaAHOEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 09:04:01 -0500
Content-Disposition: inline
In-Reply-To: <1389188139.44648.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 08, 2014 at 05:35:39AM -0800, Fran=C3=A7ois-Xavier Le Bail =
wrote:
> On Wed, 1/8/14, Fran=C3=A7ois-Xavier Le Bail <fx.lebail@yahoo.com> wr=
ote:
>=20
> > > I think there is a bug in actual net-next.
>  =20
> > > When I execute this code and press Crtl-C, all the IPv6
> > > Link-Layer addresses are deleted.
>  =20
> > > This happened between
> > > c1ddf295f5183a5189196a8035546842caa2055a and HEAD.
>  =20
> > > [...]
> =20
> > Sorry, it is not linked to this code.
> > I'm looking for the reason ...
> =20
> It seems that the valid lifetime and preferred lft are set to 0 sec f=
or autoconfigured LLA.

Grrr, I guess we should switch in addrconf_add_linklocal to call ipv6_a=
dd_addr
with INFINITY_LIFE_TIME preferred and valid lft. IFA_PERMANENT may now =
expire,
too since commit fad8da3e0 ("ipv6 addrconf: fix preferred lifetime
state-changing behavior while valid_lft is infinity").

Greetings,

  Hannes
