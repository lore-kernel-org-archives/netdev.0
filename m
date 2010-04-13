From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Tue, 13 Apr 2010 20:31:03 +0200
Message-ID: <1271183463.16881.545.camel@edumazet-laptop>
References: <20100413145944.GA7716@redhat.com>
	 <4BC48F79.5090409@siemens.com> <1271176838.16881.537.camel@edumazet-laptop>
	 <20100413173919.GC26011@redhat.com>
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
Received: from mail-bw0-f219.google.com ([209.85.218.219]:33126 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757Ab0DMSbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 14:31:09 -0400
In-Reply-To: <20100413173919.GC26011@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 20:39 +0300, Michael S. Tsirkin a =C3=A9c=
rit :

> > When a socket with inflight tx packets is closed, we dont block the
> > close, we only delay the socket freeing once all packets were deliv=
ered
> > and freed.
> >=20
>=20
> Which is wrong, since this is under userspace control, so you get
> unkillable processes.
>=20

We do not get unkillable processes, at least with sockets I was thinkin=
g
about (TCP/UDP ones).

Maybe tun sockets can behave the same ?

Herbert Acked your patch, so I guess its OK, but I think it can be
dangerous.

Anyway my feeling is that we try to add various mechanisms to keep a
hostile user flooding another one.

=46or example, UDP got memory accounting quite recently, and we added
socket backlog limits very recently. It was considered not needed few
years ago.



