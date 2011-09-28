From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible NULL dereference caused by -stable commit
 ef81bb40bf15f350fe865f31fa42f1082772a576
Date: Wed, 28 Sep 2011 14:09:09 +0200
Message-ID: <1317211749.2941.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E82FC4E.5010101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@redhat.com>,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@suse.de>,
	stable@kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Amos Kong <akong@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E82FC4E.5010101@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 28 septembre 2011 =C3=A0 18:51 +0800, Jason Wang a =C3=A9cr=
it :
> Hi all:
>=20
> A possible NULL dereference were noticed by the stable commit=20
> ef81bb40bf15f350fe865f31fa42f1082772a576 (which is a backport of=20
> 87c48fa3b4630905f98268dde838ee43626a060c). The case happens when brid=
ge=20
> froward a packet from guest to a physical nic, at this time no route =
is=20
> attached to the skb which may lead a NULL dereference in=20
> ipv6_select_ident(). -Next version have this check so it is fine. The=
=20
> following patch may be used to avoid this but may also lead the ip=20
> identification predicable, and this defect is also exist -next versio=
n=20
> when no route because we still depends on a global variable to genera=
te=20
> the identification.  Any thought on this?

1) Discussion on current kernel :

All we need here is not the route but inet_peer, so that inet_getid()
can be called on it.

If no route is given to ipv6_select_ident(), at least we can try to get
inet_peer, and release it before exiting from ipv6_select_ident()

2) On stable kernel, we already use an array
(ipv6_fragmentation_id[FID_HASH_SZ];) to make less predictables
fragments ids.

So we could get dst addr from the packet to be forwarded instead of the
(possibly NULL) route.
