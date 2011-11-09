From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-netlink: Add a new attribute to expose TCLASS
 values via netlink
Date: Wed, 09 Nov 2011 15:34:51 -0500 (EST)
Message-ID: <20111109.153451.441383099995731023.davem@davemloft.net>
References: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org, muralira@google.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932792Ab1KIUe6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 15:34:58 -0500
In-Reply-To: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon,  7 Nov 2011 16:23:11 -0800

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> commit 3ceca749668a52bd795585e0f71c6f0b04814f7b added a TOS attribute=
=2E
>=20
> Unfortunately TOS and TCLASS are both present in a dual-stack v6 sock=
et,
> furthermore they can have different values.  As such one cannot in a
> sane way expose both through a single attribute.
>=20
> Signed-off-by: Maciej =AFenczyowski <maze@google.com>

I can't see how an ipv6 mapped socket can even set the inet->tos value.

As far as I can see, only net/ipv4/ip_sockglue.c:ip_setsockopt() provid=
es
the interface to change inet->tos.

And ipv6 sockets, of any type, are provided no such vector by which to
get at those interfaces.

So inet->tos is always left at it's default value for ipv6 mapped socke=
ts,
and therefore I see no reason to report TCLASS vs. TOS separately.

In fact, what I would suggest is to do something about the lack of
ability to set inet->tos, and the best way to do that seems to be to
simply propagate the npinfo->tclass setting into inet->tos.  Performain=
g
any munging if necessary.

I'm not applying this patch.
