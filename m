From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag"
 (802.1p packet)
Date: Wed, 16 Jun 2010 16:24:19 +0200
Message-ID: <1276698259.2632.88.camel@edumazet-laptop>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com>
	 <1276466190.14011.223.camel@localhost>
	 <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com>
	 <1276534945.2074.11.camel@achroite.uk.solarflarecom.com>
	 <4C1662C3.3070708@trash.net> <1276542772.2444.13.camel@edumazet-laptop>
	 <311b59aee7d648c6124a84b5ca06ac60@dondevamos.com>
	 <1276679284.2632.22.camel@edumazet-laptop> <4C18B898.4000307@trash.net>
	 <6b5ed8108cebb1865c85e03d3244b6ed@dondevamos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	Patrick McHardy <kaber@trash.net>
To: Pedro Garcia <pedro.netdev@dondevamos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47086 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147Ab0FPOYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 10:24:23 -0400
Received: by wyb40 with SMTP id 40so5740825wyb.19
        for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 07:24:22 -0700 (PDT)
In-Reply-To: <6b5ed8108cebb1865c85e03d3244b6ed@dondevamos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 juin 2010 =C3=A0 15:28 +0200, Pedro Garcia a =C3=A9crit =
:

>=20
> In my understanding, 802.1p is a "subset" of 802.1q, and they share t=
he=20
> protocol number. We can do a 802.1p module, but in the end it will en=
d
> up reusing most of the code in 802.1q.
>=20

I was more thinking of a default ETH_P_8021Q rx handler (aka
vlan_skb_recv_minimal) with minimum handling (only accept vid=3D0 frame=
s),
being overridden by real 8021q handler if module loaded/present.

> In any case defining a VLAN 0 ends up usually in problems with which =
table=20
> the ARP entries get stored in. This patch solves the problem to whom=20
> is not using VLAN 0 explicitly, but if somebody is using VLAN 0 taggi=
ng
> it will work (whatever "work" means) as before.
>=20
> Probably a definitive fix would be not to allow the definition of VLA=
N 0=20
> in 802.1q module and provide some other way to tag priority packets w=
ithout
> using a subinterface (maybe in the same module or a new 8021p one). I=
 am=20
> having a look at the kernel to see what happens if we load two module=
s for=20
> the same protocol.=20
>=20
> By the way, the changelog I have to write is just the text before the=
=20
> patch?

Yes, you can take a look on any patch around for examples, like...

git show 6e327c11a91d190650df9aabe7d3694d4838bfa1

Check Documentation/SubmittingPatches   section 2)



