From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 0/2] tcp: Fix connect() races with timewait sockets
Date: Fri, 04 Dec 2009 14:45:59 +0100
Message-ID: <4B191297.5020304@gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com> <4B152F97.1090409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	Evgeniy Polyakov <zbr@ioremap.net>
To: kapil dakhane <kdakhane@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4B152F97.1090409@gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> [PATCH] tcp: Fix a connect() race with timewait sockets
>=20
> When we find a timewait connection in __inet_hash_connect() and reuse
> it for a new connection request, we have a race window, releasing bin=
d
> list lock and reacquiring it in __inet_twsk_kill() to remove timewait
> socket from list.
>=20
> Another thread might find the timewait socket we already chose, leadi=
ng to
> list corruption and crashes.
>=20
> Fix is to remove timewait socket from bind list before releasing the =
lock.

I cooked two patches on top of net-next-2.6 to solve the two last
race problems I am aware of.

Kapil, if you want to test them, make sure you take last net-next-2.6 s=
napshot.

=46irst patch changes __inet_hash_nolisten() and __inet6_hash()
to get a timewait parameter to be able to unhash it from ehash
at same time the new socket is inserted into ehash.

Second patch is a respin of the first patch I sent :
It makes sure __inet_has_connect() cannot give same timewait socket
to different threads.

Thanks !

Reported-by: kapil dakhane <kdakhane@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
