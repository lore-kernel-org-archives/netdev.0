From: Reindl Harald <h.reindl@thelounge.net>
Subject: Re: order 7 allocations from xt_recent
Date: Thu, 03 Jan 2013 20:51:22 +0100
Message-ID: <50E5E13A.80604@thelounge.net>
References: <20130103164315.GA18908@redhat.com> <1357232104.21409.25175.camel@edumazet-glaptop> <20130103171115.GA20982@redhat.com>  <20130103172636.GB20982@redhat.com> <1357236046.21409.25385.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3F806D77DDA18A688529B7D7"
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.thelounge.net ([91.118.73.15]:59278 "EHLO
	mail.thelounge.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901Ab3ACUJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 15:09:12 -0500
In-Reply-To: <1357236046.21409.25385.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3F806D77DDA18A688529B7D7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Am 03.01.2013 19:00, schrieb Eric Dumazet:
> On Thu, 2013-01-03 at 12:26 -0500, Dave Jones wrote:
>> On Thu, Jan 03, 2013 at 12:11:15PM -0500, Dave Jones wrote:
>>  > On Thu, Jan 03, 2013 at 08:55:04AM -0800, Eric Dumazet wrote:
>>  >  > On Thu, 2013-01-03 at 11:43 -0500, Dave Jones wrote:
>>  >  > > We had a report from a user that shows this code trying
>>  >  > > to do enormous allocations, which isn't going to work too well=
=2E.
>>  >  > >  ...
>>  >  > > Which is initialised thus..
>>  >  > >=20
>>  >  > >         ip_list_hash_size =3D 1 << fls(ip_list_tot);
>>  >  > >=20
>>  >  > > And ip_list_tot is 10000 in this case. Hmm ?
>>  >  > >=20
>>  >  > > Complete report and setup described in his bug report at https=
://bugzilla.redhat.com/show_bug.cgi?id=3D890715
>>  >  >=20
>>  >  > Yes, we had a report and a patch :
>>  >  >=20
>>  >  > http://comments.gmane.org/gmane.linux.network/248216
>>  >  >=20
>>  >  > I'll send it in a more formal way.
>>  >=20
>>  > Ah! Excellent.
>>  >=20
>>  > That 'check size and vmalloc/kmalloc accordingly' thing seems to be=
 a pattern
>>  > that comes up time and time again.  Is it worth maybe making a more=
 generic
>>  > version of that instead of open-coding it each time it comes up ?
>>
>> Something else that I'm puzzled by.
>>
>> In the report above, it failed to allocate 512kb, but..
>>
>> Node 0 Normal: 2388*4kB 347*8kB 1029*16kB 3512*32kB 29*64kB 2*128kB 1*=
256kB 5*512kB 1*1024kB 0*2048kB 0*4096kB =3D 147128kB
>>                                                                       =
      ^^^^^^^^^^^^^^^^
>>
>> Shouldn't the allocator have been able to satisfy that anyway ?
>>
>=20
> Might be something related to the CONFIG_COMPACTION=3Dy and lumpy recla=
im
> removal ?
>=20
> Anyway, we keep a fraction of memory for ATOMIC allocations

on the machine there is even "vm.min_free_kbytes" set to 128 MB
however, something goes terrible wrong if cache-pages leads to
stack-traces about failed memory allocation

vm.swappiness =3D 0
vm.overcommit_memory =3D 1
vm.overcommit_ratio =3D 60
vm.vfs_cache_pressure =3D 30
vm.dirty_background_ratio =3D 15
vm.dirty_ratio =3D 40
vm.dirty_expire_centisecs =3D 1500
vm.dirty_writeback_centisecs =3D 1500
vm.zone_reclaim_mode =3D 0
vm.min_free_kbytes =3D 131072


--------------enig3F806D77DDA18A688529B7D7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlDl4ToACgkQhmBjz394Anl/xACfeplRk9oloJ+c/oOv+WKmC/60
TFcAoJq7khHsPZn5OHp92sWg1qggVRYD
=OCj9
-----END PGP SIGNATURE-----

--------------enig3F806D77DDA18A688529B7D7--
