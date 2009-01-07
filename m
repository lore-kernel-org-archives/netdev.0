From: Grzegorz Nosek <root@localdomain.pl>
Subject: Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Wed, 7 Jan 2009 10:37:01 +0100
Message-ID: <20090107093701.GB17612@megiteam.pl>
References: <20090106230554.GB25228@eskarina.localdomain.pl> <49644526.8030205@cn.fujitsu.com> <20090107073831.GA23648@megiteam.pl> <49646993.6080802@cn.fujitsu.com> <20090107091600.GA17612@megiteam.pl> <496476FD.8090209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Grzegorz Nosek <root@localdomain.pl>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e208.rev.megiteam.pl ([77.79.226.8]:41901 "EHLO
	vadmin.megiteam.pl" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753098AbZAGJhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 04:37:04 -0500
Content-Disposition: inline
In-Reply-To: <496476FD.8090209@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On =C5=9Bro, sty 07, 2009 at 05:33:49 +0800, Li Zefan wrote:
> >> The root cgroup is read-only, so the tasks in it always bind to IN=
ADDR_ANY.
> >> For other cgroups, write is allowed only if it has no children and=
 the
> >> parent is INADDR_ANY.
> >=20
> > Yes, I like that. Will update the patch. I assume that I must check
> > list_empty(&cgroup->children)?
>=20
> Yes.
>=20
> > Should I use cgroup_lock()/cgroup_unlock()
>=20
> Yes.
>=20
> > or other locking? I think it will be safe to do without locks but w=
ould
> > rather get some expert advice.
> >=20
>=20
> No. Without locks, it races with mkdir.
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> //cgroup_lock();
>=20
> if (list_empty(&cgrp->children) &&
>     parent->ipv4_addr =3D=3D INADDR_ANY)
> 					   <--- mkdir()
> 	ipcgroup->ipv4_addr =3D new_addr;
>=20
> //cgroup_unlock();
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> In the above case, ipcgroup->ipv4_addr =3D new_addr,
> but child_cgroup->ipv4_addr =3D=3D INADDR_ANY, which is not expected.

I see. Thanks a lot!

Best regards,
 Grzegorz Nosek
