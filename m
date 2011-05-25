From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Wed, 25 May 2011 08:35:31 +0200
Message-ID: <1306305331.3305.22.camel@edumazet-laptop>
References: <201104250033.03401.maxi@daemonizer.de>
	 <1303878240.2699.41.camel@edumazet-laptop>
	 <1303878771.2699.44.camel@edumazet-laptop>
	 <201104271352.00601.maxi@daemonizer.de>
	 <20110512211033.GA3468@dev1756.snc6.facebook.com>
	 <1305234953.2831.2.camel@edumazet-laptop>
	 <20110524213327.GA3917@dev1756.snc6.facebook.com>
	 <1306291469.3305.11.camel@edumazet-laptop>
	 <20110525060609.GA32244@dev1756.snc6.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110525060609.GA32244@dev1756.snc6.facebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 24 mai 2011 =C3=A0 23:06 -0700, Arun Sharma a =C3=A9crit :
> On Wed, May 25, 2011 at 04:44:29AM +0200, Eric Dumazet wrote:
> >=20
> > Hmm, thanks for the report. Are you running x86 or another arch ?
> >=20
>=20
> This was on x86.
>=20
> > We probably need some sort of memory barrier.
> >=20
> > However, locking this central lock makes the thing too slow, I'll t=
ry to
> > use an atomic_inc_return on p->refcnt instead. (and then lock
> > unused_peers.lock if we got a 0->1 transition)
>=20
> Another possibility is to do the list_empty() check twice. Once witho=
ut
> taking the lock and again with the spinlock held.
>=20

Why ?

list_del_init(&p->unused); (done under lock of course) is safe, you can
call it twice, no problem.

No, the real problem is the  (!list_empty(&p->unused) test : It seems t=
o
not always tell the truth if not done under lock.
