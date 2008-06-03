From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next 2/13]bnx2x: Adding bnx2x_link
Date: Tue, 03 Jun 2008 02:31:19 -0400
Message-ID: <1212474679.18365.34.camel@ubuntu804desktop.localdomain>
References: <1212333127.6967.121.camel@ubuntu804desktop.localdomain>
 <87tzgc283g.fsf@basil.nowhere.org>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net, "Eliezer Tamir" <eliezert@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4581 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbYFCGbl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 02:31:41 -0400
In-Reply-To: <87tzgc283g.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-06-01 at 22:50 +0200, Andi Kleen wrote:
Andi - thank you very much for taking the time and reviewing this code.
It is really appreciated.
> Just quick general review. Logic is pretty much unscrutinizable witho=
ut
> a datasheet.
In the next patch, we will add a nice comment at the beginning of the
bnx2x_link file with general concept and explanation about the flow.

> In general your code would be much easier readable if you shortened
> some of the defines and names a bit.
>=20
> > +++ b/drivers/net/bnx2x_link.c
> > @@ -0,0 +1,4456 @@
> > +/*  Copyright 2008 Broadcom Corporation
> > + *=20
> > + *  Unless you and Broadcom execute a separate written software li=
cense
> > + *  agreement governing use of this software, this software is lic=
ensed to you
> > + *  under the terms of the GNU General Public License version 2, a=
vailable
> > + *  at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the =
"GPL").
> > + *=20
> > + *  Notwithstanding the above, under no circumstances may you comb=
ine this
> > + *  software in any way with any other Broadcom software provided =
under a
> > + *  license other than the GPL, without Broadcom's express prior w=
ritten
> > + *  consent.
>=20
> Not a lawyer, but doesn't that conflict with the GPL as additional
> restriction in case Broadcom ever released anything else e.g. under=20
> a BSD license which can be normally combined with GPL?
Not being a lawyer myself, I took this header from our legal department=
=2E
I can go back and ask them to make sure it is =C2=A8really=C2=A8 GPL if=
 you think
I should - I did not questioned it when they gave it to me

> > + *  Written by Yaniv Rosner
>=20
> And shouldn't that person be in Signed-off-by?=20
Of course he should and he was on the original attempt for this patch.
You can rest assure that he is here with me answering these comments an=
d
that he is indeed singed-off on this patch even though I mistakenly
forgot to add his name

>=20
> A high level comment what this file is supposed to do at the beginnin=
g
> of the file would be good.
Agreed - we will add it soon (on the next patch)

>=20
> > +static u8 bnx2x_reset_unicore(struct link_params *params)
> > +{
> > +	struct bnx2x *bp =3D params->bp;
> > +	u16 mii_control;
> > +	u16 i;
> > +
> > +	CL45_RD_OVER_CL22(bp, params->port,
> > +			      params->phy_addr,
> > +			      MDIO_REG_BANK_COMBO_IEEE0,
> > +			      MDIO_COMBO_IEEE0_MII_CONTROL, &mii_control);
> > +
> > +	/* reset the unicore */
> > +	CL45_WR_OVER_CL22(bp, params->port,
> > +			      params->phy_addr,
> > +			      MDIO_REG_BANK_COMBO_IEEE0,
> > +			      MDIO_COMBO_IEEE0_MII_CONTROL,
> > +			      (mii_control |
> > +			       MDIO_COMBO_IEEO_MII_CONTROL_RESET));
>=20
> Your macro naming is certainly "interesting".
:) The original code (which is currently part of bnx2x.c) was using CL2=
2
and CL45 - we changed everything to CL45 by using these accessories
macros and the "interesting" name is wrong... it should read CL22 over
CL45 - we will fix it in the next patch as well

> > +
> > +	/* wait for the reset to self clear */
> > +	for (i =3D 0; i < MDIO_ACCESS_TIMEOUT; i++) {
> > +		udelay(5);
>=20
> Hopefully that doesn't loop too often. Could tie down the machine
> for a long time.
>=20
>=20
> > +	if (rx_lane_swap !=3D 0x1b) {
> > +		CL45_WR_OVER_CL22(bp, params->port,
> > +				      params->phy_addr,
> > +				    MDIO_REG_BANK_XGXS_BLOCK2,
> > +				    MDIO_XGXS_BLOCK2_RX_LN_SWAP,
> > +				    (rx_lane_swap |
> > +				    MDIO_XGXS_BLOCK2_RX_LN_SWAP_ENABLE |
> > +				    MDIO_XGXS_BLOCK2_RX_LN_SWAP_FORCE_ENABLE));
> > +	} else {
> > +		CL45_WR_OVER_CL22(bp, params->port,
> > +				      params->phy_addr,
> > +				      MDIO_REG_BANK_XGXS_BLOCK2,
> > +				      MDIO_XGXS_BLOCK2_RX_LN_SWAP, 0);
> > +	}
>=20
> That could be written much shorter with two variables.
OK

> > +
> > +	if (tx_lane_swap !=3D 0x1b) {
=2E...
> > +	} else {
=2E...
> Same.
Same - OK

>=20
> > +			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
> > +				/* Disable 2.5Ghz */
> > +				bnx2x_cl45_read(bp, params->port,
> > +					      ext_phy_type,
> > +					      ext_phy_addr,
> > +					      MDIO_AN_DEVAD,
> > +					      0x8329, &tmp1);
> > +/* SUPPORT_SPEED_CAPABILITY
> > +				if (params->speed_cap_mask &
> > +				PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G)
> > +*/
>=20
> You seem to have a lot of commented out code like this. Remove it all=
?=20
We will clean those in the next patch

> > +	if (CHIP_REV_IS_FPGA(bp)) {
>=20
> Do the FPGA and IS_EMUL cases really need to be in a production drive=
r?
The support for FPGA and EMUL is part of the code in the main file as
well. Removing it will require a patch by it self. I will prepare such =
a
patch, but in lower priority. I agree that it has no place in the Kerne=
l

>=20
> > +u8 bnx2x_link_reset(struct link_params *params, struct link_vars *=
vars)
> > +{
=2E...
> > +	msleep(10);
>=20
> Didn't see the caller, but hopefully that's not a standard shared wor=
kqueue.
> Tieing those up for 10ms would be quite nasty.
It is not a workqueue - only user context

> There are more such long sleeps that should be double checked.
We will review all the delays in the bnx2x_link - but since a lot of
experiments need to be done with many exiting designs, it will take a
couple of weeks before we can change it. Please remember that the
existing code has the same delays - so this patch does not create a new
problem


> > +/* Programs an image to DSP's flash via the SPI port*/
> > +static u8 bnx2x_sfx7101_flash_download(struct bnx2x *bp, u8 port,
> > +				     u8 ext_phy_addr,
> > +				     char data[], u32 size)
>=20
> Hmm does the driver really need a flash updater as standard
> functionality? That could be a separate program.
>=20
> > +	/* wait 0.5 sec to allow it to run */
> > +	for (cnt =3D 0; cnt < 100; cnt++)
> > +		msleep(5);
> > +
> > +	bnx2x_hw_reset(bp);
> > +
> > +	for (cnt =3D 0; cnt < 100; cnt++)
> > +		msleep(5);
>=20
> Especially when it contains long delays like this.
Since we have a lot of code to support updating the device nvram via
ethtool -E, it seemed appropriate to add the same capability to the PHY
nvram. We can transfer the logic to an application, but I wonder why do
we differentiate the MAC nvram from the PHY nvram

> -Andi
>=20
Thanks again for all your comments. Since the existing bnx2x.c contains
most of the issues that need to be fixed, I still hope that this patch
will be accepted - it will be a lot easier for me to send another patch
with your suggestions based on the new structure, and I'm really hoppin=
g
to get the other 12/13 parts of this patch in.

Thanks,
Eilon


