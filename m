From: steve@chygwyn.com
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening
	sockets, and for IPv4 multicast forwarding
Date: Wed, 14 Oct 2009 10:27:43 +0100
Message-ID: <20091014092743.GA13374@fogou.chygwyn.com>
References: <20091007.223928.34412707.davem@davemloft.net> <55a4f86e0910140051v69441b09gd364b32f8e2d0c68@mail.gmail.com> <20091014072319.GA12095@fogou.chygwyn.com> <20091014.021505.181431380.davem@davemloft.net> <55a4f86e0910140250o45532dabr33707c025dfa25f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, atis@mikrotik.com,
	netdev@vger.kernel.org, panther@balabit.hu, eric.dumazet@gmail.com,
	brian.haley@hp.com
To: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:53020 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932461AbZJNKeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 06:34:22 -0400
Content-Disposition: inline
In-Reply-To: <55a4f86e0910140250o45532dabr33707c025dfa25f9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Oct 14, 2009 at 02:50:47AM -0700, Maciej =C5=BBenczykowski wrot=
e:
> Problem is the primary purpose of the mark is to enable matching on
> the mark in the routing tables.
>=20
> See 'ip rule  ... fwmark X ...'
>=20
> ie. that fails due to circular dependency.
>=20
>
I don't agree. There are two route lookups with a tunnel, the
internal one and the tunnel one. Here is an example of what I'm
thinking:

1. Look up a route which points at a remote ip addres via a tunnel devi=
ce.
   The "setmark" on this route sets the skb mark
2. Look up a route on the tunnel itself (i.e. the tunnel endpoint not
   the socket endpoint) using the mark from the initial lookup. This
   route can depend on the previous lookup (if there are multiple
   routes for multiple marks) and also set the mark to use.

The default would be to inherit the mark over a route lookup, in
case that no "setmark" had been specified for that route. In
other words, it would be the same as it is now.

The mark is supposed to be a generic thing, not just for routing
lookups, it can be used for classification, etc as well. I would
expect to see such a thing used for maybe specifying a VLAN or
a reference to an MPLS label stack, or something similar too,

Steve.
