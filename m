From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Tue, 30 Sep 2014 13:22:13 +1000
Message-ID: <20140930132213.0dfa99e3@canb.auug.org.au>
References: <20140930131354.792033e7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/e/JX/fF_gMe5SAgkHNp7sGg"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140930131354.792033e7@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/e/JX/fF_gMe5SAgkHNp7sGg
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Tue, 30 Sep 2014 13:13:54 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> Hi all,
>=20
> After merging the net-next tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
>=20
> net/bridge/br_nf_core.c:77:1: error: expected identifier or '(' before '{=
' token
>  {
>  ^
> net/bridge/br_nf_core.c:88:12: error: redefinition of 'br_nf_core_init'
>  int __init br_nf_core_init(void)
>             ^
> In file included from net/bridge/br_nf_core.c:23:0:
> net/bridge/br_private.h:762:19: note: previous definition of 'br_nf_core_=
init' was here
>  static inline int br_nf_core_init(void) { return 0; }
>                    ^
> net/bridge/br_nf_core.c:93:6: error: redefinition of 'br_nf_core_fini'
>  void br_nf_core_fini(void)
>       ^
> In file included from net/bridge/br_nf_core.c:23:0:
> net/bridge/br_private.h:763:20: note: previous definition of 'br_nf_core_=
fini' was here
>  static inline void br_nf_core_fini(void) {}
>                     ^
>=20
> Caused by commit 34666d467cbf ("netfilter: bridge: move br_netfilter
> out of the core").  This build has CONFIG_BRIDGE_NETFILTER not set ...
>=20
> I have applied the following patch for today:
>=20
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 30 Sep 2014 13:09:09 +1000
> Subject: [PATCH] netfilter: bridge: don't build br_nf_core unless necessa=
ry
>=20
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  net/bridge/Makefile | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/bridge/Makefile b/net/bridge/Makefile
> index 5e3eac5dc8b9..eb653a225397 100644
> --- a/net/bridge/Makefile
> +++ b/net/bridge/Makefile
> @@ -6,12 +6,11 @@ obj-$(CONFIG_BRIDGE) +=3D bridge.o
> =20
>  bridge-y	:=3D br.o br_device.o br_fdb.o br_forward.o br_if.o br_input.o \
>  			br_ioctl.o br_stp.o br_stp_bpdu.o \
> -			br_stp_if.o br_stp_timer.o br_netlink.o \
> -			br_nf_core.o
> +			br_stp_if.o br_stp_timer.o br_netlink.o
> =20
>  bridge-$(CONFIG_SYSFS) +=3D br_sysfs_if.o br_sysfs_br.o
> =20
> -obj-$(CONFIG_BRIDGE_NETFILTER) +=3D br_netfilter.o
> +obj-$(CONFIG_BRIDGE_NETFILTER) +=3D br_netfilter.o br_nf_core.o
> =20
>  bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) +=3D br_multicast.o br_mdb.o
> =20
> --=20
> 2.1.1

After whish I get this from an x86_64 allmodconfig build:

ERROR: "br_nf_core_fini" [net/bridge/bridge.ko] undefined!
ERROR: "br_netfilter_rtable_init" [net/bridge/bridge.ko] undefined!
ERROR: "br_nf_core_init" [net/bridge/bridge.ko] undefined!

So I gave up :-(

I have used the net-next tree from next-20140926 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/e/JX/fF_gMe5SAgkHNp7sGg
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUKiHqAAoJEMDTa8Ir7ZwVqJEP/2CWa8brbLZxrt9S+q4o6CE6
dxy7kXf7vnxQ7ToNAz7zTgtKYrMRryCQc7Vr86z8gRHsWIYeldI8jwV1RpuUp5K7
+fQIYP8AMRA1MG2qIowdGIDh0aS42U8xXeQh2dtJWXeHGKsKK3hG/BIYF4yOwMK6
Roa+m6Z+HVzfVAxgu4MFMdcReAF9esXcHh6q414X00NDWL///FCs36zI3pmMgOAM
Npe00ytCypk/gcIBT3zRqN2ATwxqlHsUI4soxjIByf4pwcGWFjtvUHJIRzziW5Kq
mg6L1swhdU9r//j6psDPJlwm2JiPnE/rDZ4w07UBbBiaoZF2Zy1Kf+8uRwDsRbOi
/7VixGAxlBQ7aFooeCizlSqubTCLMEWfaUzf63oBOXS5OEznQxE6zqCoFlmdRXLz
D7ClT/LUcBUkREmFZwZKfsHNLBQUj8An5senf+3IuvFyGC35r3bsqghzDPWDN9Rg
lY6TwkaC+30xj7+zTM8XZBdPfHLWRmyAWKHMhAyU9OyOkBLhEqkAFFcu3QBUC86N
GU41UQow0wD+By6x3/o5wD7+t9gBuFfE9dG69jmmgrhUnv9v+u4TARuY1RvZCKJE
GE+mkSaJHlF7IG0Vl9aebi/UMKOsxWazQiJ7KENSaBmAIDmIVrZa+OdXmc9QF/uS
MINsl6plGQ1SNqmC9qfW
=bbjg
-----END PGP SIGNATURE-----

--Sig_/e/JX/fF_gMe5SAgkHNp7sGg--
