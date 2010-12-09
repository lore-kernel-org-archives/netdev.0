From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Thu, 09 Dec 2010 03:51:59 +0100
Message-ID: <1291863119.2795.29.camel@edumazet-laptop>
References: <20101203103447.GA29714@hostway.ca>
	 <1291375743.2897.141.camel@edumazet-laptop>
	 <20101203123617.GA6993@verge.net.au>  <20101209023509.GA21216@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org
To: Simon Kirby <sim@hostway.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56421 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955Ab0LICwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 21:52:03 -0500
Received: by wyb28 with SMTP id 28so1792667wyb.19
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 18:52:02 -0800 (PST)
In-Reply-To: <20101209023509.GA21216@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 d=C3=A9cembre 2010 =C3=A0 18:35 -0800, Simon Kirby a =C3=
=A9crit :

> Right.  So, on 2.6.35, ethtool shows:
>=20
> # ethtool -k eth1
> Offload parameters for eth1:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on
> udp fragmentation offload: off
> generic segmentation offload: on
> large receive offload: off
>=20
> # ethtool -k eth1.39
> Offload parameters for eth1.39:
> rx-checksumming: on
> tx-checksumming: off
> scatter-gather: off
> tcp segmentation offload: off
> udp fragmentation offload: off
> generic segmentation offload: off
> large receive offload: off
>=20
> On 2.6.36, ethtool shows:
>=20
> # ethtool -k eth1
> Offload parameters for eth1:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on
> udp fragmentation offload: off
> generic segmentation offload: on
> large receive offload: off
>=20
> # ethtool -k eth1.39
> Offload parameters for eth1.39:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on
> udp fragmentation offload: off
> generic segmentation offload: on
> large receive offload: off
>=20
> And if I set it with ethtool -K eth1.39 gso off; ethtool -K eth1 gso =
off,
> it says "off", but I still see merged frames, as verified with an nc =
<
> /dev/zero and tcpdump -i any -n 'length > 1500'.
>=20


Yep, but you also have "tso on" by default on 2.6.36 and eth1.39 (vlan)

> > I will prepare a backport of the "ipvs: allow transmit of GRO aggre=
gated
> > skbs" patch to v2.6.36 and post it shortly.  Testing to see if that
> > resolves the problem that you are seeing would probably be a good s=
tart.
>=20
> I can test this in our case, and it should specifically work on the
> servers we were seeing the problem on, but it still needs some
> complicated logic to be safe for all cases (like when LVS decides to
> route out an interface without GRO).  Anyway, thanks!
>=20
> Simon-


