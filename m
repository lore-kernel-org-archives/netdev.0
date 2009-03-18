From: =?UTF-8?Q?Kolbj=C3=B8rn_Barmen?= <linux@kolla.no>
Subject: Re: PROBLEM: IPv6 autoconf/accept_ra default values
Date: Wed, 18 Mar 2009 02:06:09 +0100 (CET)
Message-ID: <alpine.LNX.2.00.0903180200590.10453@firda.kolla.no>
References: <alpine.LNX.2.00.0902241031470.28298@halbrend.uninett.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Kolbj=C3=B8rn_Barmen?= <linux@kolla.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ufisa.uninett.no ([158.38.152.126]:36236 "EHLO ufisa.uninett.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753671AbZCRBGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 21:06:18 -0400
In-Reply-To: <alpine.LNX.2.00.0902241031470.28298@halbrend.uninett.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Feb 2009, Kolbj=C3=B8rn Barmen wrote:

> 1. Summary of problem
>=20
> autoconfig and accept_ra is by default on (by the way of forwarning) =
-
> this is very problematic in many ways.

[snip]

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

Obviously noone really think much of this, one way or the other, so her=
e's a
patch that changes the default values.

--------
--- linux/net/ipv6/addrconf.c.orig      2009-03-17 23:41:10.000000000 +=
0100
+++ linux/net/ipv6/addrconf.c   2009-03-17 23:42:18.000000000 +0100
@@ -157,9 +157,9 @@
        .forwarding             =3D 0,
        .hop_limit              =3D IPV6_DEFAULT_HOPLIMIT,
        .mtu6                   =3D IPV6_MIN_MTU,
-       .accept_ra              =3D 1,
+       .accept_ra              =3D 0,
        .accept_redirects       =3D 1,
-       .autoconf               =3D 1,
+       .autoconf               =3D 0,
        .force_mld_version      =3D 0,
        .dad_transmits          =3D 1,
        .rtr_solicits           =3D MAX_RTR_SOLICITATIONS,
@@ -192,9 +192,9 @@
        .forwarding             =3D 0,
        .hop_limit              =3D IPV6_DEFAULT_HOPLIMIT,
        .mtu6                   =3D IPV6_MIN_MTU,
-       .accept_ra              =3D 1,
+       .accept_ra              =3D 0,
        .accept_redirects       =3D 1,
-       .autoconf               =3D 1,
+       .autoconf               =3D 0,
        .dad_transmits          =3D 1,
        .rtr_solicits           =3D MAX_RTR_SOLICITATIONS,
        .rtr_solicit_interval   =3D RTR_SOLICITATION_INTERVAL,
--------

Cheers!

-- kolla
