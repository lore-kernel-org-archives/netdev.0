From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 ipv6_select_ident
Date: Wed, 21 Dec 2011 18:36:24 +0100
Message-ID: <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EF200BB.7000209@bootc.net>
	 <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF2117F.6000803@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Chris Boot <bootc@bootc.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EF2117F.6000803@bootc.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 17:03 +0000, Chris Boot a =C3=A9=
crit :
> On 21/12/2011 16:29, Eric Dumazet wrote:
> > Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 15:52 +0000, Chris Boot a =
=C3=A9crit :
> >> Hi folks,
> >>
> >> I'm working on getting a 2-node VM cluster up and running, with DR=
BD and
> >> Corosync/Pacemaker, running KVM VMs.
> >>
> >> I can trigger a kernel panic in either _host_ system when running =
an
> >> rsync on a _guest_ VM. The rsync is simply SSH over IPv6 from a re=
mote
> >> mail store (containing maildirs) to a local filesystem. I'm basica=
lly
> >> working on migrating a physical IMAP server to one inside a VM.
> >>
> >> After a few seconds of fairly heavy IPv6 traffic, I get the panic =
below.
> >> You'll notice the panic refers to vhost_net, but I tried without t=
hat
> >> and the kernel panics at exactly the same call point.
> >>
> >> Panic:
> >>
> >> [snip]
> >>
> >> Any insight will be gratefully received.
> >>
> >> Thanks,
> >> Chris
> >>
> > Is it a debian kernel ?
> >
> > You need : https://lkml.org/lkml/2011/10/11/291
>=20
> Eric,
>=20
> Aha, that sounds like exactly the culprit, thanks. However I can't fi=
nd=20
> any reference to it in the 3.1 to 3.1.5 changelogs. Is it fixed in an=
y=20
> of those kernels or would I have to attempt to forward-port the fix m=
yself?

Good point, thats a different problem then, since 3.1 is not supposed t=
o
have this bug.

It seems rt->rt6i_peer points to invalid memory in your crash.

(RBX=3D00000000000001f4)

8b 83 a4 00 00 00       mov    0xa4(%rbx),%eax    p->refcnt
1f4+a4 -> CR2=3D0000000000000298
