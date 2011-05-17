From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Tue, 17 May 2011 14:20:23 +0200
Message-ID: <1305634823.2850.90.camel@edumazet-laptop>
References: <1305618020-72535-1-git-send-email-tsunanet@gmail.com>
	 <1305618020-72535-2-git-send-email-tsunanet@gmail.com>
	 <1305619677.2850.11.camel@edumazet-laptop>
	 <e6b52d895fca947b4cce2896d593619b@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benoit Sigoure <tsunanet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e6b52d895fca947b4cce2896d593619b@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 17 mai 2011 =C3=A0 13:02 +0200, Hagen Paul Pfeifer a =C3=A9cri=
t :
> On Tue, 17 May 2011 10:07:57 +0200, Eric Dumazet wrote:
>=20
> > I wont discuss if introducing a new sysctl is welcomed, only on pat=
ch
> > issues. I believe some work in IETF is done to reduce the 3sec valu=
e to
> > 1sec anyway.
>=20
> Why not?=20

Just because I let this point to David and others. I personally dont
care that much.

> I though all new knobs in this area should be done on a per route
> metric so it can be controlled on a per path basis. RTO should be
> adjustable on a per path basis, because it depends on the path.
>=20

Adding many knobs to each clone had a huge cost on previous kernels.
(Think some machines have millions entries in IP route cache), this use=
d
quite a lot of memory.

With latest David work, we'll consume less ram, because we can now shar=
e
settings, instead of copying them on each dst entry.



> Some months back [1] I posted a patch to enable/disable TCP quick ack
> mode, which has nothing to do with network paths, just with a local s=
erver
> policy. But David rejected the patch with the argument that I should =
use a
> per path knob (this is a little bit inapprehensible for me, but David=
 has
> the last word).

Well, if nobody speaks after David, he has the last word indeed.

BTW, I remember Stephen actually asked the per route thing, not David.

http://kerneltrap.org/mailarchive/linux-netdev/2010/8/23/6283641

Then David also stated it :

http://kerneltrap.org/mailarchive/linux-netdev/2010/8/23/6283678

If you really want tcp_quickack thing you really should do it as
requested by both Stephen & David ;)

Unfortunately, I dont know if its really needed or worthwhile.
