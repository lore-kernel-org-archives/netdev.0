From: Grzegorz Nosek <root@localdomain.pl>
Subject: Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Wed, 7 Jan 2009 10:16:00 +0100
Message-ID: <20090107091600.GA17612@megiteam.pl>
References: <20090106230554.GB25228@eskarina.localdomain.pl> <49644526.8030205@cn.fujitsu.com> <20090107073831.GA23648@megiteam.pl> <49646993.6080802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Grzegorz Nosek <root@localdomain.pl>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e208.rev.megiteam.pl ([77.79.226.8]:45783 "EHLO
	vadmin.megiteam.pl" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752547AbZAGJQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 04:16:05 -0500
Content-Disposition: inline
In-Reply-To: <49646993.6080802@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On =C5=9Bro, sty 07, 2009 at 04:36:35 +0800, Li Zefan wrote:
> Grzegorz Nosek wrote:
> >>> IP addresses are write-once (via /cgroup/.../ipaddr.ipv4 in dotte=
d-quad
> >> Why they should be write-once ?
> >=20
> > No real (technical) reason. Making it read-write would be fine with=
 me.
> > I wanted to make the restriction a one-way road but I guess I can p=
olice
> > that in userspace (simply don't write anything to the file twice).
> >=20
>=20
> But seems the patch makes it impossible to re-allow a restricted task=
 to
> be binded to INADDR_ANY.

Yes, my goal is to disallow that but I don't insist to do that in the
kernel (I'm not currently planning to let untrusted root loose in a
container).

> Firstly, is inheritance necessary ?

It would be nice to have when the container's root is untrusted but
might want to subdivide the container's cgroup for other purposes.
Without inheritance, they would be able to circumvent the IP address
restriction. One could argue that a full untrusted-root container would
need a proper network namespace anyway (and giving CAP_SYS_ADMIN there
is probably a very bad idea), but still, I'd feel uneasy.

> If yes, then how about:
>=20
> The root cgroup is read-only, so the tasks in it always bind to INADD=
R_ANY.
> For other cgroups, write is allowed only if it has no children and th=
e
> parent is INADDR_ANY.

Yes, I like that. Will update the patch. I assume that I must check
list_empty(&cgroup->children)? Should I use cgroup_lock()/cgroup_unlock=
()
or other locking? I think it will be safe to do without locks but would
rather get some expert advice.

Thanks a lot for your comments.

Best regards,
 Grzegorz Nosek
