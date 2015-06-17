From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH] isdn: disable HiSax NetJet driver on microblaze arch
Date: Wed, 17 Jun 2015 08:53:49 +0200
Message-ID: <1434524029.4280.12.camel@chaos.site>
References: <87pp4vw3ep.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>
To: Nicolai Stange <nicstange@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87pp4vw3ep.fsf@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Wednesday 17 June 2015 =C3=A0 03:05 +0200, Nicolai Stange a =C3=A9cr=
it :
> Fix an allmodconfig compilation failer on microblaze due to big endia=
n
> architectures being apparently unsupported by the NetJet code:
>   drivers/isdn/hisax/nj_s.c: In function 'setup_netjet_s':
>   drivers/isdn/hisax/nj_s.c:265:2:
>       error: #error "not running on big endian machines now"
>=20
> Modify the relevant Kconfig such that the NetJet code is not built on
> microblaze anymore.
>=20
> Note that endianess on microblaze is not determined through Kconfig,
> but by means of a compiler provided CPP macro, namely __MICROBLAZEEL_=
_.
> However, gcc defaults to big endianess on that platform.
>=20
> Signed-off-by: Nicolai Stange <nicstange@gmail.com>
> ---
>  The maintainer tree listed under "ISDN SUBSYSTEM" in MAINTAINERS doe=
s
>  not exist anymore. I created the diff against the Linus tree.
>=20
>  drivers/isdn/hisax/Kconfig | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/isdn/hisax/Kconfig b/drivers/isdn/hisax/Kconfig
> index 97465ac..eb83d94 100644
> --- a/drivers/isdn/hisax/Kconfig
> +++ b/drivers/isdn/hisax/Kconfig
> @@ -237,7 +237,7 @@ config HISAX_MIC
> =20
>  config HISAX_NETJET
>  	bool "NETjet card"
> -	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !C=
PU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
> +	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !C=
PU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZ=
E))
>  	depends on VIRT_TO_BUS
>  	help
>  	  This enables HiSax support for the NetJet from Traverse
> @@ -249,7 +249,7 @@ config HISAX_NETJET
> =20
>  config HISAX_NETJET_U
>  	bool "NETspider U card"
> -	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !C=
PU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
> +	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !C=
PU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZ=
E))
>  	depends on VIRT_TO_BUS
>  	help
>  	  This enables HiSax support for the Netspider U interface ISDN car=
d

Acked-by: Jean Delvare <jdelvare@suse.de>

--=20
Jean Delvare
SUSE L3 Support
