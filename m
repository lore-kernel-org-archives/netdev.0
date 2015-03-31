From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH net-next] ethernet: Use bool function returns of true/false
 instead of 1/0
Date: Tue, 31 Mar 2015 13:10:38 +0200
Message-ID: <551A80AE.7020506@monstr.eu>
References: <201503260524.AdqSbov9%fengguang.wu@intel.com>	 <20150325215525.GA26868@athens>	 <20150329.121655.2092434262655191613.davem@davemloft.net> <1427678712.2715.52.camel@perches.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="blfP0GASGE02qj6k4t7k1D7epi6SxLijA"
Cc: fengguang.wu@intel.com, varun@chelsio.com, kbuild-all@01.org,
	hariprasad@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ariel Elior <ariel.elior@qlogic.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	Michal Simek <michal.simek@xilinx.com>,
	=?windows-1252?Q?S=F6ren_Brinkmann?= <soren.brinkmann@xilinx.com>,
	e1000-devel@lists.sourceforge.net,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427678712.2715.52.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--blfP0GASGE02qj6k4t7k1D7epi6SxLijA
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 03/30/2015 03:25 AM, Joe Perches wrote:
> Use bool constants as the return values instead of 1 and 0.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>> To be honest I'd might rather get bunches of these, there has to be a =
ton
>> of them, than a slow trickle of one every few weeks/days.
>=20
> There aren't too many...
>=20
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 4 ++--
>  drivers/net/ethernet/xilinx/xilinx_emaclite.c    | 2 +-
>  3 files changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index 039b0c1..9980912 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -11610,7 +11610,7 @@ static bool bnx2x_get_dropless_info(struct bnx2=
x *bp)
>  	u32 cfg;
> =20
>  	if (IS_VF(bp))
> -		return 0;
> +		return false;
> =20
>  	if (IS_MF(bp) && !CHIP_IS_E1x(bp)) {
>  		/* Take function: tmp =3D func */
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers=
/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> index 02ffb30..ccaecb1 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> @@ -1351,7 +1351,7 @@ static bool reg_pattern_test(struct ixgbe_adapter=
 *adapter, u64 *data, int reg,
> =20
>  	if (ixgbe_removed(adapter->hw.hw_addr)) {
>  		*data =3D 1;
> -		return 1;
> +		return true;
>  	}
>  	for (pat =3D 0; pat < ARRAY_SIZE(test_pattern); pat++) {
>  		before =3D ixgbe_read_reg(&adapter->hw, reg);
> @@ -1376,7 +1376,7 @@ static bool reg_set_and_check(struct ixgbe_adapte=
r *adapter, u64 *data, int reg,
> =20
>  	if (ixgbe_removed(adapter->hw.hw_addr)) {
>  		*data =3D 1;
> -		return 1;
> +		return true;
>  	}
>  	before =3D ixgbe_read_reg(&adapter->hw, reg);
>  	ixgbe_write_reg(&adapter->hw, reg, write & mask);
> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/ne=
t/ethernet/xilinx/xilinx_emaclite.c
> index 2111b91..6008eee 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> @@ -1062,7 +1062,7 @@ static bool get_bool(struct platform_device *ofde=
v, const char *s)
>  	} else {
>  		dev_warn(&ofdev->dev, "Parameter %s not found,"
>  			"defaulting to false\n", s);
> -		return 0;
> +		return false;
>  	}
>  }

Kernel-doc should be also fixed in spite of this whole function is just
broken and binding should be fixed to use of_property_read_bool for
these properties.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--blfP0GASGE02qj6k4t7k1D7epi6SxLijA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAlUagK4ACgkQykllyylKDCEEnACcCNqtDTJABHBLbRnMFRZ9gMkh
4loAn3Vog07Vpc9Xwya7I1bWp1FOD98k
=0HAA
-----END PGP SIGNATURE-----

--blfP0GASGE02qj6k4t7k1D7epi6SxLijA--
