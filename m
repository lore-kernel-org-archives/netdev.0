From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: Reviewing batman-adv for net/
Date: Mon, 28 Jun 2010 10:55:45 +0200
Message-ID: <201006281055.47004.sven.eckelmann@gmx.de>
References: <201006260214.06662.sven.eckelmann@gmx.de>
	<20100627222706.GC8285@nuttenaction>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1595958.o4dbsVBH37";
	protocol="application/pgp-signature"; micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>,
	b.a.t.m.a.n-ZwoEplunGu2X36UT3dwlltHuzzzSOjJt@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20100627222706.GC8285@nuttenaction>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1595958.o4dbsVBH37
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hagen Paul Pfeifer wrote:

Thanks for your comments. Marek already answered the first two questions, a=
nd=20
I will write something about the last part.

[...]
> o The major code is twisted about bookkeeping stuff, configuration aspects
> and so on. The minor codebase is about protocol processing. What about a
> generalized architecture and a userspace implementation of the protocol?
> And communication via netlink sockets.

Even if it sounds interesting to have a userspace implementation - it just=
=20
doesn't work. Maybe you have something different in mind - so please commen=
t a=20
little bit more about about your idea.

There were different implementations for that protocol, first one was a=20
complete userspace implementation - but it was just slow and not really=20
usable. The second one was not using skb because it was only a port of the=
=20
userspace implementation to the kernel. It was faster (better throughput, n=
ot=20
as much latency added), but still we noticed that we couldn't saturate our=
=20
fast links due to the overhead we added. That was the time the current form=
 of=20
processing and forwarding using skbs was implemented. It was quite plain to=
 us=20
that those "tiny" parts must be processed as fast as possible and we are no=
t=20
able to communicate a lot inside the kernel to get the information we need =
to=20
forward packets or process new ones.

So I would assume that when we communicate with userspace which does some=20
processing of the incoming packets and changes them to get forwarded, we wo=
uld=20
have the same overhead problems as before. That means we add unnecessary=20
latency and reduce the throughput a lot.

It works quite well for layer 3 mesh protocols (olsr, batman, babel, bmx, .=
=2E)=20
because they must not care about the actual routing of the packets -=20
everything is done by the IP routing code. But it does not work for things=
=20
which must route ethernet frames as there does not exist such a framework a=
nd=20
it is hard to create one which everyone will like and has enough informatio=
n=20
to provide all features they need. Meshing with ethernet frames is relative=
=20
young (please correct me) and we see all the time that we need more things=
=20
which couldn't be done by layer 3 (or at least with a lot more work). An=20
example would be interface interface alternating which can reduce=20
interferences when communicating over many hops.

thanks,
	Sven

--nextPart1595958.o4dbsVBH37
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAABCgAGBQJMKGOSAAoJEF2HCgfBJntGaQAP/ib3QmODfzwJIfDsWgOGUugR
NR6M9pZRmFDRydblPoGJ2TZ/UCgsZQCps5hJ75S72NkfD3oVW9XowCWg0F2AMxgJ
TbKO166TeTm7QsyVEvgpeKD/P4zSqMzn5ynCl0rl2IMviCZtS0JAPR3nmWZ+ybDB
T5XqyTvmrpYCiPH5EKmLpBzgmsbTq38+W9fgcmMyMqMEmp6fUY3ce/Q14M+HVEPw
v5nBNCNAz1fKS4VBlWMFE9YHBe3H1T+jIcZqz3+9JzncooZIhpZWBpbnZ2J5/sUz
jI5J9XpcdRCNnOyjHNyI66KeupoagJZ0fajJi9Vv+8Kbz5g6togXdTmvUbngB+QR
tpNl9nEWMcVkWpDTcHQhUVs0j4baJHm8C6V5K85elH6gtytI8SbqRawqMSZIzcZc
ixX+i7IEfiUFK5YIkkZkZ+f9aggwnwzEjmWO3aOxqGOlZHC3RyqMK9AFTvfNb0r6
zLY5cpsehEVge1pCOcQIyEKu32K34eT9TfOhjBnmvnMGcwQGidOXp27ljs/29oBU
7J3N4IfOC8z3ei5twqWBI+qrcl31Jtaw3fq0P6LdwC7LxKh50GQt2H7pmIoqCMoQ
rN1JWXiAh4YBVrEeFLjvJRI74tXRxfDNeHBoKsjMqq3bpBJ3cMfA27GumwFejHAw
PqVHNU6eQ5/S4Xj/7wf/
=z3N1
-----END PGP SIGNATURE-----

--nextPart1595958.o4dbsVBH37--
