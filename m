From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Wed, 7 Jan 2009 22:54:13 +0200
Message-ID: <200901072254.14017.rdenis@simphalempin.com>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <200901071852.32078.rdenis@simphalempin.com> <20090107174809.GA8989@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:55649 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754157AbZAGUxo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 15:53:44 -0500
In-Reply-To: <20090107174809.GA8989@ioremap.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 7 janvier 2009 19:48:09 Evgeniy Polyakov, vous avez =C3=A9c=
rit=C2=A0:
> If setting that rlimit does not require admin priviledges, then it do=
es
> not require to drop this. So it is superuser or admin who does this.
> And exactly the same can be achieved with 'owner' iptables module.

No no no.

There is a huge fundamental difference between setrlimit, prctl(SECCOMP=
),=20
set*uid and chroot on the one side, and iptables on the other side: The=
 first=20
ones are APIs for a process to control its own permission. iptables is =
an=20
interface to control the _whole_ system.

In other words, the first ones are usable programmatically. iptables is=
 not,=20
unless you're willing to assume the kernel only operates one single=20
userland "software".

=46rom the perspective of distros and system admins, perhaps SELinux an=
d=20
iptables are sufficient to address this. But from that of a third-party=
,=20
upstream, distro-independent or whatever-you-want-to-call-it software v=
endor,=20
they don't quite work due to their centralized nature.

> > As I understand it, Michael is trying to build something similar to
> > SECCOMP,  only way less restrictive and way more usable by real-lif=
e
> > userland programs.=20

> Security and unpriveledged setup are mutually impossible cases.

On a high-level, sure. You need a trusted privileged entity somewhere.

But when it comes _specifically_ to "unprivileged" as in "non-root", I =
believe=20
there is a use case for something less restrictive than SECCOMP, yet mo=
re=20
restrictive than just being a normal non-root process. Something along =
the=20
lines of: cannot debug other processes, cannot send signal to them, can=
not=20
create file descriptors, cannot bind sockets, yet can allocate memory, =
can=20
read timers, can read/write from any type of (already opened) file. Or=20
whatever brighter and more knowledgeable mind than mine could define.

Or can someone prove that there is no set of permissions bigger than th=
ose of=20
SECCOMP that would effectively equate to those of a normal non-privileg=
ed=20
process?

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
