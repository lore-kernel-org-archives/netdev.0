From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is broken.
 In 4.0.0-rc3
Date: Tue, 17 Mar 2015 01:49:14 +0000
Message-ID: <BLUPR03MB373C5CF9AA7555ACC92A4F5F5030@BLUPR03MB373.namprd03.prod.outlook.com>
References: <390621425930628@web28o.yandex.ru>
	 <3625951426018334@web26j.yandex.ru>
	 <BLUPR03MB373A446E2D97992CA7AAA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
	 <726281426513068@web10o.yandex.ru>
 <BLUPR03MB3739B9C6E14A106CCAEBA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
 <994171426532944@web7m.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?koi8-r?B?8MHOz9cg4c7E0sXK?= <rockford@yandex.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0137.outbound.protection.outlook.com ([207.46.100.137]:24662
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751728AbbCQBtQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 21:49:16 -0400
In-Reply-To: <994171426532944@web7m.yandex.ru>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =F0=C1=CE=CF=D7 =E1=CE=C4=D2=C5=CA <rockford@yandex.ru> Sent: T=
uesday, March 17, 2015 3:09 AM
> To: Duan Fugang-B38611; netdev@vger.kernel.org; linux-arm-kernel
> Subject: Re: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is
> broken. In 4.0.0-rc3
>=20
> Hi!
>=20
> 16.03.2015, 17:01, "fugang.duan@freescale.com"
> <fugang.duan@freescale.com>:
> >>>
> >>> =9ADo you have any lost for reproduce the issue ?
> >> =9ACurrent net tree does not have this issue, it works fine. Thank=
s to
> all.
> >>
> >> =9AFrom git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.gi=
t
> >>
> >> =9Aapx@astra:~$ uname -r
> >> =9A4.0.0-rc3-00150-g10640d3-dirty
> >>
> >
> > I test the commit f00bbd2 that include the patch 2b995f63987.
> > But cannot reproduce your issue. Pls double confirm it in your boar=
d.
>=20
> Confirmed that net-next is buggy.
>=20
> Client kernel version:
> apx@astra:~$ uname -r
> 4.0.0-rc3-00875-gf00bbd2-dirty
>=20
> 100M file of zeros on client:
> apx@astra:~$ ls -l zeros
> -rw-r--r-- 1 apx apx 104857600 =CD=C1=D2 10 22:33 zeros
>=20
> File contents (ran on client host):
> apx@astra:~$ hd zeros
> 00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00
> |................|
> *
> 06400000
>=20
> NFS server kernel version:
> apx@ct:~$ uname -r
> 4.0.0-rc2-00480-g29e70e6
>=20
> 100M file of zeros on client:
> apx@ct:~$ ls -l zeros
> -rw-r--r-- 1 apx apx 104857600 =CD=C1=D2 10 22:33 zeros
>=20
> File contents (ran on server host):
> apx@ct:~$ hd zeros
> 00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00
> |................|
> *
> 001d4a80  1c f0 9f e5 1c f0 9f e5  1c f0 9f e5 1c f0 9f e5
> |................|
> *
> 001d4aa0  1c f0 9f e5 74 fb 00 00  bc ff 93 00 c0 ff 93 00
> |....t...........|
> 001d4ab0  c4 ff 93 00 c8 ff 93 00  cc ff 93 00 d0 ff 93 00
> |................|
> 001d4ac0  d4 ff 93 00 d8 ff 93 00  13 00 00 00 28 63 29 20
> |............(c) |
> 001d4ad0  43 6f 70 79 72 69 67 68  74 20 32 30 30 37 2d 32  |Copyrigh=
t
> 2007-2|
> 001d4ae0  30 31 32 2c 20 46 72 65  65 73 63 61 6c 65 20 53  |012,
> Freescale S|
> 001d4af0  65 6d 69 63 6f 6e 64 75  63 74 6f 72 2e 20 41 6c  |emicondu=
ctor.
> Al|
> 001d4b00  6c 20 72 69 67 68 74 73  20 72 65 73 65 72 76 65  |l rights
> reserve|
> 001d4b10  64 2e 00 00 dd 00 2c 41  11 73 00 00 d3 74 00 00
> |d.....,A.s...t..|
> 001d4b20  3d 75 00 00 a9 78 00 00  4f 78 00 00 75 77 00 00
> |=3Du...x..Ox..uw..|
> 001d4b30  07 76 00 00 c3 79 00 00  09 7a 00 00 75 7a 00 00
> |.v...y...z..uz..|
>=20
> Any other client works fine with this server.
> And note that corruption is not random, it looks like a zero page
> (vectors at beginning), so somewhere pointer to data is corrupted (an=
d
> set to zero(?)).
> This is repeated many times.
>=20
> I use an Embedsky E9 board:
> http://en.embedsky.com/product_info.php?cateid=3D169&id=3D169
> It is SabreSD-alike board with a fewer peripherials, and at network s=
ide
> it has a different PHY, instead of Atheros it has a Realtek RTL8211E,=
 and
> I have to initialize it this way (board early fixup patch):
>=20
> --- a/arch/arm/mach-imx/mach-imx6q.c
> +++ b/arch/arm/mach-imx/mach-imx6q.c
> @@ -166,6 +166,19 @@ static int ar8035_phy_fixup(struct phy_device *d=
ev)
>=20
>  #define PHY_ID_AR8035 0x004dd072
>=20
> +static int rtl8211e_phy_fixup(struct phy_device *dev) {
> +       phy_write(dev, 0x00, 0x3140);
> +       msleep(10);
> +       phy_write(dev, 0x00, 0x3340);
> +       msleep(10);
> +
> +       return 0;
> +}
> +
> +#define PHY_ID_RTL8211E 0x001cc915
> +#define REALTEK_PHY_ID_MASK 0x001fffff
> +
>  static void __init imx6q_enet_phy_init(void)  {
>         if (IS_BUILTIN(CONFIG_PHYLIB)) { @@ -177,6 +190,8 @@ static v=
oid
> __init imx6q_enet_phy_init(void)
>                                 ar8031_phy_fixup);
>                 phy_register_fixup_for_uid(PHY_ID_AR8035, 0xffffffef,
>                                 ar8035_phy_fixup);
> +               phy_register_fixup_for_uid(PHY_ID_RTL8211E,
> REALTEK_PHY_ID_MASK,
> +                               rtl8211e_phy_fixup);
>         }
>  }
>=20
> (LAKML folks told me this should go somewhere in network driver, but =
now
> it is there)
>=20
> Without this there is no network at all, and I had ran this code for =
year
> without any glitch. 3.19 kernel works fine.
> (It causes "-dirty" in kernel version)
> And different phy initialization cannot cause a non-random stream
> corruption.
>=20
> I've found commit that produces a bug by looking a changes between 3.=
19
> (surely working)  and 4.0.0-rc3 (surely non-working) in freescale net=
work
> driver.
>=20
> Hope this helps.
>=20
> --
Thank you for double confirm.
The issue cannot be reproduced at i.MX6q sabresd board with net-next 4.=
0.0-rc3-11071-gf00bbd2 kernel.
I don't have Embedsky E9 board, so cannot continue to do this work.
Do you have i.MX6q sabresd board, if you have, you can try it.

Regards,
Andy
