From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/9] Marvell PXA168 libphy handling and Berlin Ethernet
Date: Tue, 21 Oct 2014 15:03:31 -0700
Message-ID: <5446D833.1030702@gmail.com>
References: <1413881627-21639-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?QW50b2luZSBUw6luYXI=?= =?UTF-8?B?dA==?=
	<antoine.tenart@free-electrons.com>,
	Eric Miao <eric.y.miao@gmail.com>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413881627-21639-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sebastian,

On 10/21/2014 01:53 AM, Sebastian Hesselbarth wrote:
> This patch series deals with a removing a IP feature that can be foun=
d
> on all currently supported Marvell Ethernet IP (pxa168_eth, mv643xx_e=
th,
> mvneta). The MAC IP allows to automatically perform PHY auto-negotiat=
ion
> without software interaction.
>=20
> However, this feature (a) fundamentally clashes with the way libphy w=
orks
> and (b) is unable to deal with quirky PHYs that require special treat=
ment.
> In this series, pxa168_eth driver is rewritten to completely disable =
that
> feature and properly deal with libphy provided PHYs.
>=20
> This is the real patch set after an RFT sent earlier. Unfortunately, =
there
> was no testing from MMP/gplug but there was for BG2Q. However, it sti=
ll
> would be great to get a Tested-by on gplug. Also, this patch set is n=
ow
> rebased on v3.18-rc1. As usual, a branch on top of v3.18-rc1 can be f=
ound at
>=20
> git://git.infradead.org/users/hesselba/linux-berlin.git devel/bg2-bg2=
cd-eth-v1
>=20
> Patches 1-5 should go through David's net tree, I'll pick up the DT p=
atches
> 6-9.
>=20
> Compared to the RFT, there have been some changes:
> - added phy-connection-type property to BG2Q PHY DT node
> - bail out from pxa168_eth_adjust_link when there is no change in
>   PHY parameters. Also, add a call to phy_print_status.
>=20
> Patch 1 adds support for Marvell 88E3016 FastEthernet PHY that is als=
o
> integrated in Marvell Berlin BG2/BG2CD SoCs.
>=20
> Patch 2 allows to pass phy_interface_t on pxa168_eth platform_data th=
at
> is only used by mach-mmp/gplug. From the board setup, I guessed gplug=
's
> PHY is connected via RMII. The patch still isn't even compile tested.
>=20
> Patches 3-5 prepare proper libphy handling and finally remove all in-=
driver
> PHY mangling related to the feature explained above.
>=20
> Patches 6-9 add corresponding ethernet DT nodes to BG2, BG2CD, add a
> phy-connection-type property to BG2Q and enable ethernet on BG2-based=
 Sony
> NSZ-GS7. I have tested all this on GS7 successfully with ip=3Ddhcp on=
 100M FD.

Besides the misplacement of the 'phy-connection-type' as reported by
Sergei, this looks good to me:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!

>=20
> Antoine T=C3=A9nart (1):
>   ARM: berlin: Add phy-connection-type to BG2Q PHY
>=20
> Sebastian Hesselbarth (8):
>   phy: marvell: Add support for 88E3016 FastEthernet PHY
>   net: pxa168_eth: Provide phy_interface mode on platform_data
>   net: pxa168_eth: Prepare proper libphy handling
>   net: pxa168_eth: Remove HW auto-negotiaion
>   net: pxa168_eth: Remove in-driver PHY mangling
>   ARM: berlin: Add BG2 ethernet DT nodes
>   ARM: berlin: Add BG2CD ethernet DT nodes
>   ARM: berlin: Enable ethernet on Sony NSZ-GS7
>=20
>  arch/arm/boot/dts/berlin2-sony-nsz-gs7.dts |   2 +
>  arch/arm/boot/dts/berlin2.dtsi             |  36 +++++
>  arch/arm/boot/dts/berlin2cd.dtsi           |  36 +++++
>  arch/arm/boot/dts/berlin2q.dtsi            |   1 +
>  arch/arm/mach-mmp/gplugd.c                 |   2 +
>  drivers/net/ethernet/marvell/pxa168_eth.c  | 248 ++++++++++++-------=
----------
>  drivers/net/phy/marvell.c                  |  46 ++++++
>  include/linux/marvell_phy.h                |   1 +
>  include/linux/pxa168_eth.h                 |   1 +
>  9 files changed, 225 insertions(+), 148 deletions(-)
>=20
> ---
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: "Antoine T=C3=A9nart" <antoine.tenart@free-electrons.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Eric Miao <eric.y.miao@gmail.com>
> Cc: Haojian Zhuang <haojian.zhuang@gmail.com>
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: netdev@vger.kernel.org
> Cc: devicetree@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
>=20
