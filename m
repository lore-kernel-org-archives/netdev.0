From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Tue, 13 Apr 2010 23:43:07 +0300
Message-ID: <20100413204307.GC3582@redhat.com>
References: <20100413145944.GA7716@redhat.com> <4BC48F79.5090409@siemens.com> <1271176838.16881.537.camel@edumazet-laptop> <20100413173919.GC26011@redhat.com> <1271183463.16881.545.camel@edumazet-laptop> <20100413202548.GA3582@redhat.com> <1271191086.16881.570.camel@edumazet-laptop>
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
Received: from mx1.redhat.com ([209.132.183.28]:52228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752793Ab0DMUsY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 16:48:24 -0400
Content-Disposition: inline
In-Reply-To: <1271191086.16881.570.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 13, 2010 at 10:38:06PM +0200, Eric Dumazet wrote:
> Le mardi 13 avril 2010 =E0 23:25 +0300, Michael S. Tsirkin a =E9crit =
:
> > On Tue, Apr 13, 2010 at 08:31:03PM +0200, Eric Dumazet wrote:
> > > Le mardi 13 avril 2010 =E0 20:39 +0300, Michael S. Tsirkin a =E9c=
rit :
> > >=20
> > > > > When a socket with inflight tx packets is closed, we dont blo=
ck the
> > > > > close, we only delay the socket freeing once all packets were=
 delivered
> > > > > and freed.
> > > > >=20
> > > >=20
> > > > Which is wrong, since this is under userspace control, so you g=
et
> > > > unkillable processes.
> > > >=20
> > >=20
> > > We do not get unkillable processes, at least with sockets I was t=
hinking
> > > about (TCP/UDP ones).
> > >=20
> > > Maybe tun sockets can behave the same ?
> >=20
> > Looks like that's what my patch does: ip_rcv seems to call
> > skb_orphan too.
>=20
> Well, I was speaking of tx side, you speak of receiving side.

Point is, both ip_rcv and my patch call skb_orphan.

> An external flood (coming from another domain) is another problem.
>=20
> A sender might flood the 'network' inside our domain. How can we
> reasonably limit the sender ?
>=20
> Maybe the answer is 'We can not', but it should be stated somewhere, =
so
> that someone can address this point later.
>=20

And whatever's done should ideally work for tap to IP
and IP to IP sockets as well, not just tap to tap.

--=20
MST
