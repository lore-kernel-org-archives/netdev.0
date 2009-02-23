From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: IPv6 autoconf/accept_ra default values
Date: Mon, 23 Feb 2009 15:46:21 -0800 (PST)
Message-ID: <20090223.154621.08279126.davem@davemloft.net>
References: <alpine.LNX.2.00.0902231319380.14151@halbrend.uninett.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: linux@kolla.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41530
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751828AbZBWXqk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2009 18:46:40 -0500
In-Reply-To: <alpine.LNX.2.00.0902231319380.14151@halbrend.uninett.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kolbj=F8rn Barmen <linux@kolla.no>
Date: Mon, 23 Feb 2009 15:42:41 +0100 (CET)

>=20
> Hello
>=20
> 1. Summary of problem

You'll get more replies if you contact the networking developers
at netdev@vger.kernel.org

> autoconfig and accept_ra is by default on (by the way of forwarning) =
-
> this is very problematic in many ways.
>=20
> 2. Full description of the problem/report:
>=20
> * if you want staticly only configured addresses/gateway (which is
>   something you just might want for server machines for example) you =
need
>   to change the sysctl parameters before the interface is brought up.=
=20
>   (yes, I want staticly, and only staticly configured addresses, dont=
 get
>   me started on why - keywords: source address, dns, ssl, access cont=
rol)
>=20
> * to change the default values, ipv6 module needs to be loaded, in ma=
ny
>   distros this leads to race conditions, especially in these "autodet=
ect
>   hardware and bring up everything magically" days :)
>=20
> * if you netboot with ipv6 enabled kernel, interface will pick up ipv=
6
>   autoconf no matter, so you need to remove addresses and routes manu=
ally
>   after boot. As far as I know there is now kernel parameters to tell
>   kernel to not autoconf ipv6. I admit I have not tested out whether =
it's
>   possible to use ipv6-addresses as kernel parameters at all.
>=20
> * ipv6 kernel module has no load paramters as far as I can tell?
>=20
> * changing net.ipv6.conf.all.* and net.ipv6.conf.default.* dont work =
as
>   intended? I'm really not sure how this is meant to work, but intuit=
ively
>   I would think that "...all.*" would affect all interfaces present, =
and
>   "...*.default.*" would set the default values for "future" interfac=
es.
>   Maybe I'm wrong? Look further down...
>=20
> 3. Keywords
>    ipv6, forwarding, autoconf, accept_ra
>=20
> 4. Kernel version (from /proc/version):
>    This goes accross all 2.6 kernels as far as I can tell, no matter =
what
>    distro.
>=20
> 5. Output of Oops.. message
>    No oops so far :)
>=20
> 6. A small shell script or example program which triggers the problem=
=20
>   =20
>    root:~# sysctl net.ipv6.conf.all.accept_ra
>    net.ipv6.conf.all.accept_ra =3D 1
>    root:~# sysctl -w net.ipv6.conf.all.accept_ra=3D0
>    net.ipv6.conf.all.accept_ra =3D 0
>    root:~# sysctl net.ipv6.conf.eth0.accept_ra
>    net.ipv6.conf.all.accept_ra =3D 1
>   =20
> I suppose the above is fals behaviour? I'm really not sure, but if th=
is is
> not a bug, then I fail to see the purpose of the "...all.*" and
> "...default.*" sysctl parameters. From the documentation
> (networking/ip-sysctl.txt) I get the impression that the above behavi=
our
> is wrong:
>=20
> ---=20
> conf/default/*:
>         Change the interface-specific default settings.
>=20
> conf/all/*:
>         Change all the interface-specific settings.
>=20
>         [XXX:  Other special features than forwarding?]
> ---
>=20
> Looks like this is unclear for more than just me :)
>=20
>=20
> My personal oppinion is that anything ipv6 autoconfig/accept_ra shoul=
d be
> default _off_, since this simplifies all the above mentioned issues, =
and
> it is incredibly easy to turn on again with systcl if people want it.
> It is much easier to enable ipv6 automagic than to disable it.
> At least there should be kernel/module parameter to set default behav=
iour.
>=20
> Part of the problem with deploying IPv6 is due to "magic" like this, =
all
> the autoconfig/router announcement magic looks very well on paper and=
 in
> theory, but out in the field it quickly leads to loads of totally
> unnecessary extra work, work that could easily be avoided if default
> behaviour was to have it off. It should be in the interest of IPv6
> advocates to support a "soft" transition from IPv4-only to dual-stack=
,
> fencing off unwanted "magic" only adds to the frustration for those w=
ho
> actually try to deploy it.
>=20
> What do you think?
>=20
> If there already is a simple stright forward solution, then I apologi=
ze
> for this rant - please enlighten me :)
>=20
> -- kolla
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
