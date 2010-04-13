From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Tue, 13 Apr 2010 22:38:06 +0200
Message-ID: <1271191086.16881.570.camel@edumazet-laptop>
References: <20100413145944.GA7716@redhat.com>
	 <4BC48F79.5090409@siemens.com> <1271176838.16881.537.camel@edumazet-laptop>
	 <20100413173919.GC26011@redhat.com>
	 <1271183463.16881.545.camel@edumazet-laptop>
	 <20100413202548.GA3582@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Kiszka <jan.kiszka@siemens.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Paul Moore <paul.moore@hp.com>,
	David Woodhouse <David.Woodhouse@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qemu-devel <qemu-devel@nongnu.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:35777 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711Ab0DMUiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 16:38:12 -0400
In-Reply-To: <20100413202548.GA3582@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 23:25 +0300, Michael S. Tsirkin a =C3=A9c=
rit :
> On Tue, Apr 13, 2010 at 08:31:03PM +0200, Eric Dumazet wrote:
> > Le mardi 13 avril 2010 =C3=A0 20:39 +0300, Michael S. Tsirkin a =C3=
=A9crit :
> >=20
> > > > When a socket with inflight tx packets is closed, we dont block=
 the
> > > > close, we only delay the socket freeing once all packets were d=
elivered
> > > > and freed.
> > > >=20
> > >=20
> > > Which is wrong, since this is under userspace control, so you get
> > > unkillable processes.
> > >=20
> >=20
> > We do not get unkillable processes, at least with sockets I was thi=
nking
> > about (TCP/UDP ones).
> >=20
> > Maybe tun sockets can behave the same ?
>=20
> Looks like that's what my patch does: ip_rcv seems to call
> skb_orphan too.

Well, I was speaking of tx side, you speak of receiving side.
An external flood (coming from another domain) is another problem.

A sender might flood the 'network' inside our domain. How can we
reasonably limit the sender ?

Maybe the answer is 'We can not', but it should be stated somewhere, so
that someone can address this point later.



