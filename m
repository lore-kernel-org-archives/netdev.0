From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT] Networking
Date: Mon, 21 Mar 2011 21:10:55 +0100
Message-ID: <1300738255.2837.1.camel@edumazet-laptop>
References: <20110320.195156.226769634.davem@davemloft.net>
	 <AANLkTinN3qszBjbJdkXb2TPBkAW0mXGC=Ri1zKL9gdNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinN3qszBjbJdkXb2TPBkAW0mXGC=Ri1zKL9gdNg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 21 mars 2011 =C3=A0 12:24 -0700, Linus Torvalds a =C3=A9crit :
> On Sun, Mar 20, 2011 at 7:51 PM, David Miller <davem@davemloft.net> w=
rote:
> >
> > 1) The R8169 PHY fix from Eric Dumazet, which I see you've added to
> >   your tree too. :-)
>=20
> Yeah, since my machine didn't have networking without it, and I could
> test it myself, I didn't wait to pull.
>=20
> That said, I'm delaying this pull request due to the known issues wit=
h
> it - let me know when you've updated it with the fix for the
> use-after-free fixes and the slab corruptor (the latter of which I
> haven't seen a patch for yet)

Seems to be related to one typo, but still we have to find the
corruption

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_=
ctl.c
index b799cea..33733c8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3605,7 +3605,7 @@ int __net_init __ip_vs_control_init(struct net *n=
et)
=20
 	/* procfs stats */
 	ipvs->tot_stats.cpustats =3D alloc_percpu(struct ip_vs_cpu_stats);
-	if (ipvs->tot_stats.cpustats) {
+	if (!ipvs->tot_stats.cpustats) {
 		pr_err("%s(): alloc_percpu.\n", __func__);
 		return -ENOMEM;
 	}
