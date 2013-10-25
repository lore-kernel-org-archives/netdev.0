From: Wolfgang Walter <linux@stwm.de>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Fri, 25 Oct 2013 11:33:38 +0200
Message-ID: <1940187.0cLVhJSJb8@h2o.as.studentenwerk.mhn.de>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de> <5743349.5WGxWa1M1u@ei.h3.stusta.mhn.de> <20131025080158.GC31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:34256 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751610Ab3JYJdk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Oct 2013 05:33:40 -0400
In-Reply-To: <20131025080158.GC31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 25. Oktober 2013, 10:01:58 schrieb Steffen Klassert:
> On Thu, Oct 24, 2013 at 12:52:58AM +0200, Wolfgang Walter wrote:
> > On Wednesday 23 October 2013 10:06:32 Eric Dumazet wrote:
> > > On Wed, 2013-10-23 at 18:59 +0200, Wolfgang Walter wrote:
> > > > Ah, ok. I use SLUB, but SLABINFO=3Dy.
> > > >=20
> > > > Without much traffic it is:
> > > >=20
> > > > # grep dst /proc/slabinfo
> > > > xfrm_dst_cache      4435   4608    448   36    4 : tunables    =
0    0=20
> > > >   0
> > > >=20
> > > > : slabdata    128    128      0
> > > >=20
> > > > on the big one.
> > > >=20
> > > > I can recompile the kernels with SLAB instead of SLUB if SLAB g=
ives
> > > > more
> > > > usefull infos.
> > >=20
> > > Not needed, because it seems we do not merge this SLUB cache with
> > > another one.
> >=20
> > Ok. I can't see xfrm_dst_cache on 32bit-systems, though.
> >=20
> > > So please post this information, because I believe the default sh=
ould be
> > > 65536, not 1024 or 4096
> >=20
> > Indeed I already saw higher values, at the moment I see:
> >=20
> > # while true; do grep dst /proc/slabinfo ; sleep 1; done
> > xfrm_dst_cache     12636  12636    448   36    4 : tunables    0   =
 0    0
> > : slabdata    351    351      0
> We currently start the garbage collector if we have more than gc_thre=
sh
> (1024) dst entries allocated and refuse new allocations at 2 * gc_thr=
esh.
>=20
> So maybe we should set gc_thresh to 32768. Than we can have 65536 dst
> entries in the system (cache + packets in flight) before we refuse
> new allocations. In paticular we can still cache another 32768 dst
> entries after the garbage collector was started. It looks like you
> had never more than 15000 dst entries cached, so a default of 32768
> looks reasonable and should also keep smaller embedded routers happy.

The maximum I saw was 18000. I think 32768 is a good value especially a=
s this=20
seems to be the minimum on 3.4.x if you have 512MB ram.

Is it possible to log a warning the first time one hits the limit? Some=
thing=20
like "xfrm_dst_cache full, consider increasing net.ipv4.xfrm4_gc_thresh=
 and/or=20
net.ipv6.xfrm6_gc_thresh"?

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
