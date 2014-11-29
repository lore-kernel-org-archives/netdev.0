From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH, regression against -rc6] net/stmmac: fix one more regression from filter bins setting
Date: Sat, 29 Nov 2014 17:26:42 +0100
Message-ID: <5807934.FFPy2gmHBj@wuerfel>
References: <5388366.Y15J6TLmlA@wuerfel> <tencent_0FE25D6968E3D939662D9E00@qq.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, khilman <khilman@kernel.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	olof <olof@lixom.net>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: =?utf-8?B?6ZmI5Y2O5omN?= <chenhc@lemote.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:65360 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbaK2Q1h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 11:27:37 -0500
In-Reply-To: <tencent_0FE25D6968E3D939662D9E00@qq.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 29 November 2014 23:44:23 =E9=99=88=E5=8D=8E=E6=89=8D wrote=
:
> Hi, Arnd,
>=20
> Maybe this patch is better?
> http://www.spinics.net/lists/netdev/msg306413.html

Yes, that would work too. I also checked that my version works now.

I'm fine with either one, as long as a fix makes it into 3.18.

	Arnd

> ------------------ Original ------------------
> From:  "Arnd Bergmann"<arnd@arndb.de>;
> Date:  Sat, Nov 29, 2014 08:03 PM
> To:  "David Miller"<davem@davemloft.net>;
> Cc:  "netdev"<netdev@vger.kernel.org>; "khilman"<khilman@kernel.org>;=
 "Huacai Chen"<chenhc@lemote.com>; "Giuseppe Cavallaro"<peppe.cavallaro=
@st.com>; "olof"<olof@lixom.net>; "linux-arm-kernel"<linux-arm-kernel@l=
ists.infradead.org>;
> Subject:  [PATCH, regression against -rc6] net/stmmac: fix one more r=
egression from filter bins setting
> =20
> Commit 571dcfde2371 ("stmmac: platform: fix default values of the fil=
ter
> bins setting") tries to fix a regression in the stmmac driver, but in=
stead
> it also causes a new regression and makes all DT-based users of this
> driver fail, as found by the automated ARM boot testing:
>=20
> [    0.881667] Unable to handle kernel NULL pointer dereference at vi=
rtual address 00000048
> [    0.889784] pgd =3D c0204000
> [    0.892502] [00000048] *pgd=3D00000000
> [    0.896090] Internal error: Oops: 805 [#1] SMP ARM
> [    0.900874] Modules linked in:
> [    0.903943] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.18.0-rc6-0=
0150-g8891063 #1
> [    0.911502] task: ee06c000 ti: ee070000 task.ti: ee070000
> [    0.916899] PC is at stmmac_pltfr_probe+0x40/0x5d0
> [    0.921689] LR is at devm_ioremap_nocache+0x54/0x74
> [    0.926561] pc : [<c0642df8>]    lr : [<c0430508>]    psr: 8000015=
3
> [    0.926561] sp : ee071e50  ip : 00000000  fp : 00000000
> [    0.938020] r10: c0c14f74  r9 : ee3ca2c0  r8 : ee101c10
> [    0.943237] r7 : f00c0000  r6 : ee101c00  r5 : ee101c10  r4 : 0000=
0000
> [    0.949755] r3 : 00000001  r2 : 00000040  r1 : a0000153  r0 : f00c=
0000
> [    0.956274] Flags: Nzcv  IRQs on  FIQs off  Mode SVC_32  ISA ARM  =
Segment kernel
> [    0.963658] Control: 10c5387d  Table: 4020406a  DAC: 00000015
> [    0.969395] Process swapper/0 (pid: 1, stack limit =3D 0xee070248)
> [    0.975384] Stack: (0xee071e50 to 0xee072000)
> [    0.979738] 1e40:                                     c0d83aa0 ee1=
01c10 c0cfc030 fffffdfb
> [    0.987906] 1e60: 00000000 ee3ca2c0 c0c14f74 c056c6d0 c056c68c c0d=
83aa0 ee101c10 00000000
> [    0.996075] 1e80: c0cfc030 c056af54 ee101c10 c0cfc030 ee101c44 c0c=
f15f8 c0c616a0 c056b158
> [    1.004243] 1ea0: 00000000 c0cfc030 c056b0cc c0569514 ee01675c ee0=
d86b4 c0cfc030 ee3c9300
> [    1.012412] 1ec0: 00000000 c056a77c c0ad7be0 ee071ef8 c0cfc030 c0c=
fc030 ee070000 c0be0ca8
> [    1.020580] 1ee0: 00000000 c056b77c 00000000 c0c616a0 ee070000 c0b=
e0cbc c0c616a0 c0208cb0
> [    1.028750] 1f00: ee011900 c0d6c324 ee0b6600 c08a6748 00000000 000=
00000 00006a40 c034782c
> [    1.036918] 1f20: 00000000 c0ca1aac 60000153 00000001 c0b9f598 ef7=
fcd9c ef7fcd99 c025ffa0
> [    1.045087] 1f40: c0ae650c ef7fcda0 00000006 00000006 c0ca1a94 c0c=
50d44 00000006 c0c14f6c
> [    1.053255] 1f60: c0d46a40 c0d46a40 000000ff c0c14f74 00000000 c0b=
9fda4 00000006 00000006
> [    1.061423] 1f80: c0b9f598 9c041042 00000000 c089460c 00000000 000=
00000 00000000 00000000
> [    1.069591] 1fa0: 00000000 c0894614 00000000 c020e878 00000000 000=
00000 00000000 00000000
> [    1.077759] 1fc0: 00000000 00000000 00000000 00000000 00000000 000=
00000 00000000 00000000
> [    1.085926] 1fe0: 00000000 00000000 00000000 00000000 00000013 000=
00000 18044434 8a444414
> [    1.094113] [<c0642df8>] (stmmac_pltfr_probe) from [<c056c6d0>] (p=
latform_drv_probe+0x44/0xa4)
> [    1.102719] [<c056c6d0>] (platform_drv_probe) from [<c056af54>] (d=
river_probe_device+0x108/0x23c)
> [    1.111582] [<c056af54>] (driver_probe_device) from [<c056b158>] (=
__driver_attach+0x8c/0x90)
> [    1.120011] [<c056b158>] (__driver_attach) from [<c0569514>] (bus_=
for_each_dev+0x6c/0xa0)
> [    1.128182] [<c0569514>] (bus_for_each_dev) from [<c056a77c>] (bus=
_add_driver+0x148/0x1f0)
> [    1.136438] [<c056a77c>] (bus_add_driver) from [<c056b77c>] (drive=
r_register+0x78/0xf8)
> [    1.144434] [<c056b77c>] (driver_register) from [<c0be0cbc>] (stmm=
ac_init+0x14/0x3c)
> [    1.152176] [<c0be0cbc>] (stmmac_init) from [<c0208cb0>] (do_one_i=
nitcall+0x8c/0x1c4)
> [    1.160004] [<c0208cb0>] (do_one_initcall) from [<c0b9fda4>] (kern=
el_init_freeable+0x13c/0x1dc)
> [    1.168699] [<c0b9fda4>] (kernel_init_freeable) from [<c0894614>] =
(kernel_init+0x8/0xe8)
> [    1.176785] [<c0894614>] (kernel_init) from [<c020e878>] (ret_from=
_fork+0x14/0x3c)
> [    1.184348] Code: 8a0000fe e5964064 e3a02040 e3a03001 (e5842048)
> [    1.190501] ---[ end trace 724411f6ae142767 ]---
> [    1.195158] Kernel panic - not syncing: Attempted to kill init! ex=
itcode=3D0x0000000b
>=20
> Where the original patch left out the non-DT probe method, the fix th=
at
> was merged for -rc7 instead broke the DT path by dereferencing a NULL
> pointer.
>=20
> This patch reverts the broken fix and tries to put the initialization
> for multicast_filter_bins/unicast_filter_entries in the right place,
> which prevents non-DT users from overriding the defaults as a side
> effect, as before. Alternatively, one could change all instances of
> the platform_data definition to set the values themselves, but it's
> probably safer to do that as a follow-up.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 571dcfde2371 ("stmmac: platform: fix default values of the fil=
ter bins setting")
> Link: http://arm-soc.lixom.net/bootlogs/mainline/v3.18-rc6-150-g88910=
63/cubie2-arm-multi_v7_defconfig.html
> ---
> I've sent this off to the build bots, but it will probably take some =
more
> time before it's been tested on all the ARM machines and I might not =
be
> there to see the results, so I'm sending it out now for review. I wil=
l
> reply once I am sure the problem is fixed.
>=20
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/=
drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 5b0da3986216..94c3cefaa2c3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -177,6 +177,12 @@ static int stmmac_probe_config_dt(struct platfor=
m_device *pdev,
>  	 */
>  	plat->maxmtu =3D JUMBO_LEN;
> =20
> +	/* Set default value for multicast hash bins */
> +	plat->multicast_filter_bins =3D HASH_TABLE_SIZE;
> +
> +	/* Set default value for unicast filter entries */
> +	plat->unicast_filter_entries =3D 1;
> +
>  	/*
>  	 * Currently only the properties needed on SPEAr600
>  	 * are provided. All other properties should be added
> @@ -264,13 +270,6 @@ static int stmmac_pltfr_probe(struct platform_de=
vice *pdev)
>  	 return PTR_ERR(addr);
> =20
>  	plat_dat =3D dev_get_platdata(&pdev->dev);
> -
> -	/* Set default value for multicast hash bins */
> -	plat_dat->multicast_filter_bins =3D HASH_TABLE_SIZE;
> -
> -	/* Set default value for unicast filter entries */
> -	plat_dat->unicast_filter_entries =3D 1;
> -
>  	if (pdev->dev.of_node) {
>  	 if (!plat_dat)
>  	 plat_dat =3D devm_kzalloc(&pdev->dev,
> @@ -286,6 +285,12 @@ static int stmmac_pltfr_probe(struct platform_de=
vice *pdev)
>  	 pr_err("%s: main dt probe failed", __func__);
>  	 return ret;
>  	 }
> +	} else {
> +	 /* Set default value for multicast hash bins */
> +	 plat_dat->multicast_filter_bins =3D HASH_TABLE_SIZE;
> +
> +	 /* Set default value for unicast filter entries */
> +	 plat_dat->unicast_filter_entries =3D 1;
>  	}
> =20
>  	/* Custom setup (if needed) */
