From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.34-rc5-git6] EIP: is at inet6_csk_bind_conflict +
 06xe/0xb7 [ipv6]
Date: Sun, 25 Apr 2010 18:39:57 +0200
Message-ID: <1272213597.2069.32.camel@edumazet-laptop>
References: <l2z2d0a357f1004250811w6da355ebp95d1730473026c22@mail.gmail.com>
	 <4BD45E68.4080900@example.com>
	 <g2z2d0a357f1004250931pf5880c60l32fd0643e0f14bde@mail.gmail.com>
	 <4BD46F9C.5060500@example.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sedat.dilek@gmail.com, Sedat Dilek <sedat.dilek@googlemail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jiri Olsa <jolsa@redhat.com>,
	Jongman Heo <jongman.heo@gmail.com>
To: piotr@hosowicz.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BD46F9C.5060500@example.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 25 avril 2010 =C3=A0 18:36 +0200, Piotr Hosowicz a =C3=A9cr=
it :
> On 25.04.2010 18:31, Sedat Dilek wrote:
> > [ CCing netdev ML ]
> >
> > Confirmed: The revert-patch [1] fixes the problem here.
>=20
> I confirm, I've built a git6 kernel and it works fine.
>=20
> > See also "Bug 15847 -  crash in inet6_csk_bind_conflict" [2].
> >
> > Feel free to add a... Tested-by: Sedat Dilek<sedat.dilek@gmail.com>
>=20
> I added created and tested phrase in my archive. ;-) Thank you a lot.=
 I=20
> hope there will be no this error in git7.
>=20

Did you test the proposed fix ?


[PATCH] ipv6: Fix inet6_csk_bind_conflict()

Commit fda48a0d7a84 (tcp: bind() fix when many ports are bound)
introduced a bug on IPV6 part.
We should not call ipv6_addr_any(inet6_rcv_saddr(sk2)) but
ipv6_addr_any(inet6_rcv_saddr(sk)) because sk2 can be IPV4, while sk is
IPV6.

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connecti=
on_sock.c
index b4b7d40..3a4d92b 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -48,7 +48,7 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 			     ipv6_rcv_saddr_equal(sk, sk2))
 				break;
 			else if (sk->sk_reuse && sk2->sk_reuse &&
-				!ipv6_addr_any(inet6_rcv_saddr(sk2)) &&
+				!ipv6_addr_any(inet6_rcv_saddr(sk)) &&
 				ipv6_rcv_saddr_equal(sk, sk2))
 				break;
 		}
