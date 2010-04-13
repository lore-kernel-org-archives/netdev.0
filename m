From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Tue, 13 Apr 2010 20:39:19 +0300
Message-ID: <20100413173919.GC26011@redhat.com>
References: <20100413145944.GA7716@redhat.com> <4BC48F79.5090409@siemens.com> <1271176838.16881.537.camel@edumazet-laptop>
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
Received: from mx1.redhat.com ([209.132.183.28]:39307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983Ab0DMRoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 13:44:32 -0400
Content-Disposition: inline
In-Reply-To: <1271176838.16881.537.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 13, 2010 at 06:40:38PM +0200, Eric Dumazet wrote:
> Le mardi 13 avril 2010 =E0 17:36 +0200, Jan Kiszka a =E9crit :
> > Michael S. Tsirkin wrote:
> > > The following situation was observed in the field:
> > > tap1 sends packets, tap2 does not consume them, as a result
> > > tap1 can not be closed.
> >=20
> > And before that, tap1 may not be able to send further packets to an=
yone
> > else on the bridge as its TX resources were blocked by tap2 - that'=
s
> > what we saw in the field.
> >=20
>=20
> After the patch, tap1 is able to flood tap2, and tap3/tap4 not able t=
o
> send one single frame. Is it OK ?

Yes :) This was always possible. Number of senders needed to flood
a receiver might vary depending on send/recv queue size
that you set. External sources can also fill your RX queue
if you let them. In the end, we need to rely on the scheduler for fairn=
ess,
or apply packet shaping.

> Back to the problem : tap1 cannot be closed.
>=20
> Why ? because of refcounts ?

Yes.

> When a socket with inflight tx packets is closed, we dont block the
> close, we only delay the socket freeing once all packets were deliver=
ed
> and freed.
>=20

Which is wrong, since this is under userspace control, so you get
unkillable processes.

--=20
MST
