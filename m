From: Wolfgang Walter <linux@stwm.de>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Thu, 24 Oct 2013 00:52:58 +0200
Message-ID: <5743349.5WGxWa1M1u@ei.h3.stusta.mhn.de>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de> <3169911.kTmZ0BZVVr@h2o.as.studentenwerk.mhn.de> <1382547992.7572.31.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.stusta.mhn.de ([141.84.69.5]:37839 "EHLO
	mail.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633Ab3JWW7r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 18:59:47 -0400
In-Reply-To: <1382547992.7572.31.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 October 2013 10:06:32 Eric Dumazet wrote:
> On Wed, 2013-10-23 at 18:59 +0200, Wolfgang Walter wrote:
> > Ah, ok. I use SLUB, but SLABINFO=3Dy.
> >=20
> > Without much traffic it is:
> >=20
> > # grep dst /proc/slabinfo
> > xfrm_dst_cache      4435   4608    448   36    4 : tunables    0   =
 0    0
> > : slabdata    128    128      0
> >=20
> > on the big one.
> >=20
> > I can recompile the kernels with SLAB instead of SLUB if SLAB gives=
 more
> > usefull infos.
> Not needed, because it seems we do not merge this SLUB cache with
> another one.

Ok. I can't see xfrm_dst_cache on 32bit-systems, though.

>=20
> So please post this information, because I believe the default should=
 be
> 65536, not 1024 or 4096
>=20

Indeed I already saw higher values, at the moment I see:

# while true; do grep dst /proc/slabinfo ; sleep 1; done
xfrm_dst_cache     12636  12636    448   36    4 : tunables    0    0  =
  0 : slabdata    351    351      0
xfrm_dst_cache     12636  12636    448   36    4 : tunables    0    0  =
  0 : slabdata    351    351      0
xfrm_dst_cache     12636  12636    448   36    4 : tunables    0    0  =
  0 : slabdata    351    351      0
xfrm_dst_cache     12636  12636    448   36    4 : tunables    0    0  =
  0 : slabdata    351    351      0
xfrm_dst_cache     12636  12636    448   36    4 : tunables    0    0  =
  0 : slabdata    351    351      0
xfrm_dst_cache     12636  12636    448   36    4 : tunables    0    0  =
  0 : slabdata    351    351      0
xfrm_dst_cache     12636  12636    448   36    4 : tunables    0    0  =
  0 : slabdata    351    351      0
xfrm_dst_cache     12636  12636    448   36    4 : tunables    0    0  =
  0 : slabdata    351    351      0
xfrm_dst_cache     12636  12636    448   36    4 : tunables    0    0  =
  0 : slabdata    351    351      0
xfrm_dst_cache     12636  12636    448   36    4 : tunables    0    0  =
  0 : slabdata    351    351      0
xfrm_dst_cache     12636  12636    448   36    4 : tunables    0    0  =
  0 : slabdata    351    351      0
xfrm_dst_cache     12708  12708    448   36    4 : tunables    0    0  =
  0 : slabdata    353    353      0
xfrm_dst_cache     11529  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11599  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11599  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11599  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11599  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11599  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11599  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11599  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11599  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11599  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11599  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11633  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11633  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11633  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11700  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11763  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11798  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     11964  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     12139  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     12244  12276    448   36    4 : tunables    0    0  =
  0 : slabdata    341    341      0
xfrm_dst_cache     12312  12312    448   36    4 : tunables    0    0  =
  0 : slabdata    342    342      0
xfrm_dst_cache     12492  12492    448   36    4 : tunables    0    0  =
  0 : slabdata    347    347      0



Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
