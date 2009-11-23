From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange CPU load when flushing route cache (kernel 2.6.31.6)
Date: Mon, 23 Nov 2009 11:29:14 +0100
Message-ID: <4B0A63FA.5000804@gmail.com>
References: <1258970332.29747.262.camel@jdb-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Robert Olsson <robert@herjulf.net>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59271 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756321AbZKWK3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 05:29:11 -0500
In-Reply-To: <1258970332.29747.262.camel@jdb-workstation>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer a =C3=A9crit :
> Hi Eric and netdev,
>=20
> I have observed a strange route cache behaviour when I upgraded some
> of my production Linux routers (1Gbit/s tg3) to kernel 2.6.31.6 (from
> kernel 2.6.25.7).
>=20
> Every time the route cache is flushed I get a CPU spike (in softirq)
> with a tail.  I have attached some graphs that illustrate the issue
> (hope vger.kernel.org will allow these attachments...)
>=20
>=20
> I have done some tuning of the route cache:
>=20
>  # From /etc/sysctl.conf
>  #
>  # Adjusting the route cache flush interval
>  net/ipv4/route/secret_interval =3D 1200
>=20
>  # Limiting the route cache size
>  # ip_dst_cache slab objects is 256 bytes.
>  # 2000000 * 256 bytes =3D 512 MB
>  net/ipv4/route/max_size =3D 2000000
>=20
> Boot parameters: "rhash_entries=3D262143 vmalloc=3D256M"
>=20
> The rhash_entries is for the route cache hash size.  The vmalloc is
> needed because I have _very_ large iptables rulesets (and is running
> on a 32-bit kernel, due to old hardware).
>=20
> Any thoughs on how to avoid these CPU spikes?
> Or where the issue occurs in the code?
>=20

Sure, after a flush, we have to rebuild the cache, so extra work is exp=
ected.

(We receive a packet, notice the cached entry is obsolete, free it, all=
ocate a new one
and inert it into cache)

If you dont want these spikes, just dont flush cache :)

Do you run a 2G/2G User/Kernel split kernel ?

