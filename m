From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 0% cpu usasge after fresh boot or net restart but 10% CPU if
 kernel  flush route cache
Date: Wed, 27 Jan 2010 16:26:16 +0100
Message-ID: <1264605976.3197.8.camel@edumazet-laptop>
References: <41ac0f9e1001260858o7d2a6a6dgb37ecfba5c325932@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: cold cold <nedkonedev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44631 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762Ab0A0P13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 10:27:29 -0500
Received: by bwz19 with SMTP id 19so4770723bwz.28
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 07:27:26 -0800 (PST)
In-Reply-To: <41ac0f9e1001260858o7d2a6a6dgb37ecfba5c325932@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 janvier 2010 =C3=A0 18:58 +0200, cold cold a =C3=A9crit :
> HI,
>=20
>=20
> i have expiriance some CPU usage spikes up to 10% on each four cpus
> after the first kernel route cache flush.
> After mashine start first 20 min CPU is 0%si  300Mbits/s full duplex
> and arount 100k pps forwarded traffic, without any firewall, just
> plain routing.
>=20
> route -n |wc -l
> 34
>=20
> ip route show cache | wc -l
> 2140842
>=20
> cat /proc/sys/net/ipv4/route/secret_interval
> 600
> cat /proc/sys/net/ipv4/route/max_size
> 33554432
>=20
> after kernel  flush i got 10% on all CPUs for 5-6 mins.  It's not fro=
m
> rebuilding route cashe becouse after
> fresh boot or network restrat there is no CPU usage until kernel flus=
h
> route cache.
> I try to play with rhash_entries=3D 300000 to 2000000 same result.

If you have one million dst entries to flush, it takes some time.

You could try to not increase the rhash_entries=20
(or keep it low, say 131072)
but tune /proc/sys/net/ipv4/route settings.

Try to reduce gc_elasticity from 8 to 2
Try to reduce gc_interval from 60 to 1

Important thing to consider is to irq affinities (so that one cpu
handles network interrupts, to minimize cache ping poings )



