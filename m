From: Liviu Dudau <Liviu.Dudau@arm.com>
Subject: Re: [PATCH] sky2: Add module parameter for passing the MAC address
Date: Wed, 5 Aug 2015 18:18:13 +0100
Message-ID: <20150805171812.GH20890@e106497-lin.cambridge.arm.com>
References: <1438789854-29194-1-git-send-email-Liviu.Dudau@arm.com>
 <CAD0U-h+Lbz+bygVCaF1Ji0VPLfh9sn504rCeGigXLER+H=KnZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Ryan Harkin <ryan.harkin@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAD0U-h+Lbz+bygVCaF1Ji0VPLfh9sn504rCeGigXLER+H=KnZg@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 05, 2015 at 06:15:37PM +0100, Ryan Harkin wrote:
>    On 5 August 2015 at 16:50, Liviu Dudau <[1]Liviu.Dudau@arm.com> wr=
ote:
>=20
>      For designs where EEPROMs are not connected to PCI Yukon2
>      chips we need to get the MAC address from the firmware.
>      Add a module parameter called 'mac_address' for this. It
>      will be used if no DT node can be found and the B2_MAC
>      register holds an invalid value.
>=20
>      Signed-off-by: Liviu Dudau <[2]Liviu.Dudau@arm.com>
>=20
>    Looks good to me.=C2=A0 FWIW, you can have a tested or reviewed-by=
 at your preference:
>    Tested-by: Ryan Harkin <[3]ryan.harkin@linaro.org>
>    Reviewed-by: Ryan Harkin <[4]ryan.harkin@linaro.org>
>=20

Thanks Ryan, I think one can provide both tags, so I will use them toge=
ther.

Best regards,
Liviu

>    =C2=A0
>=20
>      ---
>      =C2=A0drivers/net/ethernet/marvell/sky2.c | 14 +++++++++++++-
>      =C2=A01 file changed, 13 insertions(+), 1 deletion(-)
>=20
>      diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/e=
thernet/marvell/sky2.c
>      index d9f4498..a977d95 100644
>      --- a/drivers/net/ethernet/marvell/sky2.c
>      +++ b/drivers/net/ethernet/marvell/sky2.c
>      @@ -101,6 +101,10 @@ static int legacy_pme =3D 0;
>      =C2=A0module_param(legacy_pme, int, 0);
>      =C2=A0MODULE_PARM_DESC(legacy_pme, "Legacy power management");
>=20
>      +/* Ugh!=C2=A0 Let the firmware tell us the hardware address */
>      +static int mac_address[ETH_ALEN] =3D { 0, };
>      +module_param_array(mac_address, int, NULL, 0);
>      +
>      =C2=A0static const struct pci_device_id sky2_id_table[] =3D {
>      =C2=A0 =C2=A0 =C2=A0 =C2=A0 { PCI_DEVICE(PCI_VENDOR_ID_SYSKONNEC=
T, 0x9000) }, /* SK-9Sxx */
>      =C2=A0 =C2=A0 =C2=A0 =C2=A0 { PCI_DEVICE(PCI_VENDOR_ID_SYSKONNEC=
T, 0x9E00) }, /* SK-9Exx */
>      @@ -4811,13 +4815,21 @@ static struct net_device *sky2_init_netd=
ev(struct sky2_hw *hw, unsigned port,
>      =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* try to get mac address in the fol=
lowing order:
>      =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* 1) from device tree data
>      =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* 2) from internal registers s=
et by bootloader
>      +=C2=A0 =C2=A0 =C2=A0 =C2=A0 * 3) from the command line paramete=
r
>      =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>      =C2=A0 =C2=A0 =C2=A0 =C2=A0 iap =3D of_get_mac_address(hw->pdev-=
>dev.of_node);
>      =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (iap)
>      =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(d=
ev->dev_addr, iap, ETH_ALEN);
>      -=C2=A0 =C2=A0 =C2=A0 =C2=A0else
>      +=C2=A0 =C2=A0 =C2=A0 =C2=A0else {
>      =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy_f=
romio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8,
>      =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ETH_ALEN);
>      +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!is_=
valid_ether_addr(&dev->dev_addr[0])) {
>      +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0int i;
>      +
>      +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < ETH_ALEN; i++)
>      +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->dev_addr[i] =3D ma=
c_address[i];
>      +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>      +=C2=A0 =C2=A0 =C2=A0 =C2=A0}
>=20
>      =C2=A0 =C2=A0 =C2=A0 =C2=A0 return dev;
>      =C2=A0}
>      --
>      2.4.6
>=20
> References
>=20
>    Visible links
>    1. mailto:Liviu.Dudau@arm.com
>    2. mailto:Liviu.Dudau@arm.com
>    3. mailto:ryan.harkin@linaro.org
>    4. mailto:ryan.harkin@linaro.org

--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
| I would like to |
| fix the world,  |
| but they're not |
| giving me the   |
 \ source code!  /
  ---------------
    =C2=AF\_(=E3=83=84)_/=C2=AF
