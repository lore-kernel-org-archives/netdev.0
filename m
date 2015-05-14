From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warnings after merge of the net-next tree
Date: Thu, 14 May 2015 17:12:06 +1000
Message-ID: <20150514171206.2fe660ec@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/NRSwGq3r=QpARwCuys5DYij"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/NRSwGq3r=QpARwCuys5DYij
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (sparc64 defconfi=
g)
produced these warnings:

In file included from arch/sparc/include/asm/cmpxchg.h:4:0,
                 from arch/sparc/include/asm/atomic_64.h:11,
                 from arch/sparc/include/asm/atomic.h:4,
                 from include/linux/atomic.h:4,
                 from include/linux/spinlock.h:416,
                 from include/linux/mmzone.h:7,
                 from include/linux/gfp.h:5,
                 from include/linux/mm.h:9,
                 from net/packet/af_packet.c:56:
net/packet/af_packet.c: In function 'packet_rcv_has_room':
arch/sparc/include/asm/cmpxchg_64.h:43:22: warning: value computed is not u=
sed [-Wunused-value]
 #define xchg(ptr,x) ((__typeof__(*(ptr)))__xchg((unsigned long)(x),(ptr),s=
izeof(*(ptr))))
                      ^
net/packet/af_packet.c:1314:3: note: in expansion of macro 'xchg'
   xchg(&po->pressure, !has_room);
   ^
net/packet/af_packet.c: In function 'packet_poll':
arch/sparc/include/asm/cmpxchg_64.h:43:22: warning: value computed is not u=
sed [-Wunused-value]
 #define xchg(ptr,x) ((__typeof__(*(ptr)))__xchg((unsigned long)(x),(ptr),s=
izeof(*(ptr))))
                      ^
net/packet/af_packet.c:3817:3: note: in expansion of macro 'xchg'
   xchg(&po->pressure, 0);
   ^

Introduced by commit 2ccdbaa6d55b ("packet: rollover lock contention
avoidance").

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/NRSwGq3r=QpARwCuys5DYij
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVVErMAAoJEMDTa8Ir7ZwVm1IP/jskvbLwZRYzlmBsHznhl2lS
znmNmPOKI3JTcfj6a/wBUvK/yobCyh025wy7Y8OzNu+mf8y1/bz7yCJN013kmMe2
ViZwr+/U4WqSgEEwoZrHl/ab/R9v8TfJA/6beTNVBJcu4fekRnYJJQk0ukwYASc6
hhYfjmQozNiDgTw6bTnnJEv8Z9UhZQgNjwlXwvvN/jzHeqCnf9NYoPsoX70DTWsv
LLURF6lrSL2NzKbPDuaOSVOHm7r7ib0e3t4G7RxifC400p5LIXxOmKrgFJCaJAnc
Bt36eVLEWDYctBE31Tf/CtrUPEznh7uAb6D7e6Wd7+l8M9zO22Mc39ndfdz7wbn6
RKrv9dnJGBiPer2Cxp6WBe88DCwDZweqvJPDV/41RKGp4E+3SfnKKmeFvwImN6re
lrrA4rE0lOa9cwtNqXD1VAF7ma1D+gfl6bKed2PM8bKIoG6N2cBRDu/p4OE/FATU
Ecxx7cvOwH5i+r5hqd07RdEzjhyswZwKqOsGzqlVYx+OJrxgnVk4NACurOIDcznl
EcLOdNcGY2IXRYoLYwKxuXdeWOohg1vTNAOY+z0ibFbz2Um/DBT12L5jYaDKnbyx
vct2rrIn2DVYH7LGNBov3LoeRj/2yXzuZLcl9HMYsEgLiisdilGDgS19vBEQizEF
hJPXOeNI4VMggfFj/lvw
=HjIS
-----END PGP SIGNATURE-----

--Sig_/NRSwGq3r=QpARwCuys5DYij--
