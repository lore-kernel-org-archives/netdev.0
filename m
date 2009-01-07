From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Thu, 8 Jan 2009 00:42:28 +0300
Message-ID: <20090107214228.GA4610@ioremap.net>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <200901071852.32078.rdenis@simphalempin.com> <20090107174809.GA8989@ioremap.net> <200901072254.14017.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: =?utf-8?B?UsOpbWk=?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:58673 "EHLO
	tservice.net.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762083AbZAGVma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 16:42:30 -0500
Content-Disposition: inline
In-Reply-To: <200901072254.14017.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 10:54:13PM +0200, R=C3=A9mi Denis-Courmont (rde=
nis@simphalempin.com) wrote:
> No no no.
>=20
> There is a huge fundamental difference between setrlimit, prctl(SECCO=
MP),=20
> set*uid and chroot on the one side, and iptables on the other side: T=
he first=20
> ones are APIs for a process to control its own permission. iptables i=
s an=20
> interface to control the _whole_ system.
>=20
> In other words, the first ones are usable programmatically. iptables =
is not,=20
> unless you're willing to assume the kernel only operates one single=20
> userland "software".

iptables 'owner' match module exactly 'operates one signel userland sof=
tware'.

> From the perspective of distros and system admins, perhaps SELinux an=
d=20
> iptables are sufficient to address this. But from that of a third-par=
ty,=20
> upstream, distro-independent or whatever-you-want-to-call-it software=
 vendor,=20
> they don't quite work due to their centralized nature.

Actually selinux is even better example although this does depend on th=
e
distro. System which wants to secure network connections already knows
what is the netfilter. This dependency equals to the recent-enough
kernel with the new rlimit.

To be clear: I do _not_ object against this patch. This is likely a goo=
d
idea and while it potentially can be implemented via different way, it
has its right for the existance :)

> > > As I understand it, Michael is trying to build something similar =
to
> > > SECCOMP,  only way less restrictive and way more usable by real-l=
ife
> > > userland programs.=20
>=20
> > Security and unpriveledged setup are mutually impossible cases.
>=20
> On a high-level, sure. You need a trusted privileged entity somewhere=
=2E
>=20
> But when it comes _specifically_ to "unprivileged" as in "non-root", =
I believe=20
> there is a use case for something less restrictive than SECCOMP, yet =
more=20
> restrictive than just being a normal non-root process. Something alon=
g the=20
> lines of: cannot debug other processes, cannot send signal to them, c=
annot=20
> create file descriptors, cannot bind sockets, yet can allocate memory=
, can=20
> read timers, can read/write from any type of (already opened) file. O=
r=20
> whatever brighter and more knowledgeable mind than mine could define.
>=20
> Or can someone prove that there is no set of permissions bigger than =
those of=20
> SECCOMP that would effectively equate to those of a normal non-privil=
eged=20
> process?

We have a good capabilities subsystem and it has proper layered design.
But still rlimit has to be assigned by something higher in this
hierarchy.

--=20
	Evgeniy Polyakov
