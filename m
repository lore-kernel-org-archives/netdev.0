From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Tue, 13 Apr 2010 18:40:38 +0200
Message-ID: <1271176838.16881.537.camel@edumazet-laptop>
References: <20100413145944.GA7716@redhat.com>
	 <4BC48F79.5090409@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Paul Moore <paul.moore@hp.com>,
	David Woodhouse <David.Woodhouse@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qemu-devel <qemu-devel@nongnu.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:56681 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752754Ab0DMQko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 12:40:44 -0400
In-Reply-To: <4BC48F79.5090409@siemens.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 17:36 +0200, Jan Kiszka a =C3=A9crit :
> Michael S. Tsirkin wrote:
> > The following situation was observed in the field:
> > tap1 sends packets, tap2 does not consume them, as a result
> > tap1 can not be closed.
>=20
> And before that, tap1 may not be able to send further packets to anyo=
ne
> else on the bridge as its TX resources were blocked by tap2 - that's
> what we saw in the field.
>=20

After the patch, tap1 is able to flood tap2, and tap3/tap4 not able to
send one single frame. Is it OK ?

Back to the problem : tap1 cannot be closed.

Why ? because of refcounts ?

When a socket with inflight tx packets is closed, we dont block the
close, we only delay the socket freeing once all packets were delivered
and freed.



