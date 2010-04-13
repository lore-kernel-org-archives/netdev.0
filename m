From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Tue, 13 Apr 2010 23:25:48 +0300
Message-ID: <20100413202548.GA3582@redhat.com>
References: <20100413145944.GA7716@redhat.com> <4BC48F79.5090409@siemens.com> <1271176838.16881.537.camel@edumazet-laptop> <20100413173919.GC26011@redhat.com> <1271183463.16881.545.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Kiszka <jan.kiszka@siemens.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Paul Moore <paul.moore@hp.com>,
	David Woodhouse <David.Woodhouse@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qemu-devel <qemu-devel@nongnu.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29416 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753143Ab0DMUai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 16:30:38 -0400
Content-Disposition: inline
In-Reply-To: <1271183463.16881.545.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 13, 2010 at 08:31:03PM +0200, Eric Dumazet wrote:
> Le mardi 13 avril 2010 =E0 20:39 +0300, Michael S. Tsirkin a =E9crit =
:
>=20
> > > When a socket with inflight tx packets is closed, we dont block t=
he
> > > close, we only delay the socket freeing once all packets were del=
ivered
> > > and freed.
> > >=20
> >=20
> > Which is wrong, since this is under userspace control, so you get
> > unkillable processes.
> >=20
>=20
> We do not get unkillable processes, at least with sockets I was think=
ing
> about (TCP/UDP ones).
>=20
> Maybe tun sockets can behave the same ?

Looks like that's what my patch does: ip_rcv seems to call
skb_orphan too.

> Herbert Acked your patch, so I guess its OK, but I think it can be
> dangerous.
> Anyway my feeling is that we try to add various mechanisms to keep a
> hostile user flooding another one.
>=20
> For example, UDP got memory accounting quite recently, and we added
> socket backlog limits very recently. It was considered not needed few
> years ago.
>=20



