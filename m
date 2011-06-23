From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Thu, 23 Jun 2011 15:29:20 +1000
Message-ID: <20110623152920.31b28b00.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__23_Jun_2011_15_29_20_+1000_7hk2pSyZxG2640eb"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__23_Jun_2011_15_29_20_+1000_7hk2pSyZxG2640eb
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/ll_temac_main.c: In function 'temac_dma_bd_release':
drivers/net/ll_temac_main.c:209:4: error: implicit declaration of function =
'dma_unmap_single'
drivers/net/ll_temac_main.c:215:3: error: implicit declaration of function =
'dma_free_coherent'
drivers/net/ll_temac_main.c: In function 'temac_dma_bd_init':
drivers/net/ll_temac_main.c:243:2: error: implicit declaration of function =
'dma_alloc_coherent'
drivers/net/ll_temac_main.c:243:14: warning: assignment makes pointer from =
integer without a cast
drivers/net/ll_temac_main.c:251:14: warning: assignment makes pointer from =
integer without a cast
drivers/net/ll_temac_main.c:280:3: error: implicit declaration of function =
'dma_map_single'
drivers/net/ll_temac_main.c: In function 'temac_start_xmit_done':
drivers/net/ll_temac_main.c:628:22: warning: cast to pointer from integer o=
f different size

I suspect that this was caused by commit b7f080cfe223 ("net: remove mm.h
inclusion from netdevice.h").

I have left the build broken for now since it is also broken for other
reasons.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__23_Jun_2011_15_29_20_+1000_7hk2pSyZxG2640eb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOAs8wAAoJEDMEi1NhKgbs99wH/Rb4znjuvFlSqnV26JJhGrMF
qh2AiutkLzs3EnDvbiEx9XHSrvziM27yOc7AiiwR0yx7tFcqteGm/sd9loSD8RCb
TvQQ0XY6/To5vScGwcLty1a+NXZBQLpjZyVvZ97z27eJ5PC10o0R8j5SR2adCQgO
evliMP623M9l5eaH6/V6jnaW4uI5M6UIoOB6EdtiI/T66ha1PLXemFgbtTnHt9On
Uq2mte2tzMTeOJmavjCX2F1FmvgH70ihA1NcR5/HH70mJNzPwcDcspplL6tzFBNv
asLVqsHSRHHAl+51JKhUp5eYD/H2Wd7t+5Hk+Y/Tf6H+5eK0/EopVxqX5zUqDQ4=
=wIRf
-----END PGP SIGNATURE-----

--Signature=_Thu__23_Jun_2011_15_29_20_+1000_7hk2pSyZxG2640eb--
