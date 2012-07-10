From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [trivial PATCH 1/7] ixgb: use PCI_VENDOR_ID_*
Date: Tue, 10 Jul 2012 15:41:18 -0700
Message-ID: <1341960078.3336.41.camel@jtkirshe-mobl>
References: <1341959492-31389-1-git-send-email-jdmason@kudzu.us>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OYD41FZOzr5GHL6PbMFP"
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341959492-31389-1-git-send-email-jdmason@kudzu.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-OYD41FZOzr5GHL6PbMFP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-07-10 at 15:31 -0700, Jon Mason wrote:
> Use PCI_VENDOR_ID_* from pci_ids.h instead of creating #define locally.
>=20
> Signed-off-by: Jon Mason <jdmason@kudzu.us>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Cc: Alex Duyck <alexander.h.duyck@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgb/ixgb_hw.c   |    5 +++--
>  drivers/net/ethernet/intel/ixgb/ixgb_ids.h  |    5 -----
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c |   10 +++++-----
>  3 files changed, 8 insertions(+), 12 deletions(-)

This should go through David Miller's networking tree's.  Adding netdev
mailing list.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

>=20
> diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_hw.c b/drivers/net/ethe=
rnet/intel/ixgb/ixgb_hw.c
> index 99b69ad..bf9a220 100644
> --- a/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
> +++ b/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
> @@ -32,6 +32,7 @@
> =20
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> =20
> +#include <linux/pci_ids.h>
>  #include "ixgb_hw.h"
>  #include "ixgb_ids.h"
> =20
> @@ -96,7 +97,7 @@ static u32 ixgb_mac_reset(struct ixgb_hw *hw)
>  	ASSERT(!(ctrl_reg & IXGB_CTRL0_RST));
>  #endif
> =20
> -	if (hw->subsystem_vendor_id =3D=3D SUN_SUBVENDOR_ID) {
> +	if (hw->subsystem_vendor_id =3D=3D PCI_VENDOR_ID_SUN) {
>  		ctrl_reg =3D  /* Enable interrupt from XFP and SerDes */
>  			   IXGB_CTRL1_GPI0_EN |
>  			   IXGB_CTRL1_SDP6_DIR |
> @@ -271,7 +272,7 @@ ixgb_identify_phy(struct ixgb_hw *hw)
>  	}
> =20
>  	/* update phy type for sun specific board */
> -	if (hw->subsystem_vendor_id =3D=3D SUN_SUBVENDOR_ID)
> +	if (hw->subsystem_vendor_id =3D=3D PCI_VENDOR_ID_SUN)
>  		phy_type =3D ixgb_phy_type_bcm;
> =20
>  	return phy_type;
> diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ids.h b/drivers/net/eth=
ernet/intel/ixgb/ixgb_ids.h
> index 2a58847..32c1b30 100644
> --- a/drivers/net/ethernet/intel/ixgb/ixgb_ids.h
> +++ b/drivers/net/ethernet/intel/ixgb/ixgb_ids.h
> @@ -33,11 +33,6 @@
>  ** The Device and Vendor IDs for 10 Gigabit MACs
>  **********************************************************************/
> =20
> -#define INTEL_VENDOR_ID             0x8086
> -#define INTEL_SUBVENDOR_ID          0x8086
> -#define SUN_VENDOR_ID               0x108E
> -#define SUN_SUBVENDOR_ID            0x108E
> -
>  #define IXGB_DEVICE_ID_82597EX      0x1048
>  #define IXGB_DEVICE_ID_82597EX_SR   0x1A48
>  #define IXGB_DEVICE_ID_82597EX_LR   0x1B48
> diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/et=
hernet/intel/ixgb/ixgb_main.c
> index 5fce363..4e5a060 100644
> --- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
> +++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
> @@ -54,13 +54,13 @@ MODULE_PARM_DESC(copybreak,
>   *   Class, Class Mask, private data (not used) }
>   */
>  static DEFINE_PCI_DEVICE_TABLE(ixgb_pci_tbl) =3D {
> -	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX,
> +	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX,
>  	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> -	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_CX4,
> +	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX_CX4,
>  	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> -	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_SR,
> +	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX_SR,
>  	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> -	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR,
> +	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX_LR,
>  	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> =20
>  	/* required last entry */
> @@ -195,7 +195,7 @@ ixgb_irq_enable(struct ixgb_adapter *adapter)
>  {
>  	u32 val =3D IXGB_INT_RXT0 | IXGB_INT_RXDMT0 |
>  		  IXGB_INT_TXDW | IXGB_INT_LSC;
> -	if (adapter->hw.subsystem_vendor_id =3D=3D SUN_SUBVENDOR_ID)
> +	if (adapter->hw.subsystem_vendor_id =3D=3D PCI_VENDOR_ID_SUN)
>  		val |=3D IXGB_INT_GPI0;
>  	IXGB_WRITE_REG(&adapter->hw, IMS, val);
>  	IXGB_WRITE_FLUSH(&adapter->hw);



--=-OYD41FZOzr5GHL6PbMFP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJP/K+OAAoJEOVv75VaS+3Oap0P/2oQI3c1n1azQFzfD4VN+YDI
WKp4JyX2To15mUppyvT9xy5bErXlI8NSV643/rexWWK+XoF79VASCngoun+k38CM
dRSMOF9v6ZND54+9hpl3+EuXvCI7VxoCQqN2L3sP/XG4NqgTD28cf4PycZ4REPGb
jdBQkYIxJiWosb5/a5uRjmFE4vx1OkQJqPnYm590ddYztwCgQ4D/w+4xZECDw/TS
crUKkdy5kuqCkKDz347aLpxDiq9HiCQ4RvH/REEOodXASYA2QUtMW8H61wSIFhMz
QVGfDh06nHS2/6Xn7QzcPU87i24D6XM2nuBJUDixWoCSLmJ8/ZELlxg9cDuzawzG
twRgCB3W0AS6nmEH09EQua3KP/WUs/ShsGANfOyl2AsvMpj6IHVvZ8seKbg+n/fX
UMAFSYuhDsdcV6gdyUg7I4PffL4pAEIYHi9MS/vRSJkwrlai+DDJbkIstVjIb3c5
s8a/D5cRWZqPtr1Z+od4KlpjBxntpUSI7NEN38qteU0hSqi6+adelG/WRQdU/tVf
F3WFh1y13osTBHqREynX2lyRl2TtQjOkyKf8270EYOqmO10izcobUtJpB0MSQCWa
VFKrLzI1zPcZnuRTg6xeyKM2CjG5Y0GS09tSyEJ2L4QqwQ6CqxqnFQnExr9jjlt0
62v9fRNt9TRLt36R3R0c
=/vVu
-----END PGP SIGNATURE-----

--=-OYD41FZOzr5GHL6PbMFP--
