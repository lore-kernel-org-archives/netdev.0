From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: guard against coalescing packets from buggy
 network drivers
Date: Fri, 25 Apr 2014 08:43:15 -0700
Message-ID: <1398440595.29914.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <535A78ED.3020309@secomea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Svenning =?ISO-8859-1?Q?S=F8rensen?= <sss@secomea.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <535A78ED.3020309@secomea.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-04-25 at 17:02 +0200, Svenning S=C3=B8rensen wrote:
> This patch adds a guard against coalescing packets received by buggy =
network
> drivers that don't initialize skb->tail properly.
>=20
> Coalescing such packets will corrupt data in a way that makes it hard=
 to
> track down the real cause of the problem. Observed symptoms are a flo=
od of
> WARNs by tcp_recvmsg at random times, leaving no clear indication as =
to why
> the packet buffers were corrupted. See for example this thread:
> https://groups.google.com/forum/#!topic/linux.kernel/A8ZI9aXooSU
>=20
> Obviously the correct thing to do is fixing the drivers in question (=
eg. by
> using skb_put() instead of just setting skb->len) - this patch will=20
> hopefully
> help to track them down with less effort than I had to put into it :)
>=20
> NB: in my case it was an out-of-tree Bluegiga WiFi driver; a quick lo=
ok=20
> indicates
> that there are in-tree drivers (for hardware that I don't own) with t=
he=20
> same bug.
>=20
>=20
> Signed-off-by: Svenning Soerensen <sss@secomea.com>

If you want a debugging patch, this should happen way before TCP stack
or even IP stack.

Say you want to use this buggy driver on a router, this code path will
never bit hit.
