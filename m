From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: Re: [PATCH 2/2] au1000-eth: convert to platform_driver model
Date: Tue, 10 Nov 2009 10:20:25 +0100
Message-ID: <f861ec6f0911100120j12d86b0cs3ef9c2816019eaf9@mail.gmail.com>
References: <200911100113.38685.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ralf Baechle <ralf@linux-mips.org>,
	linux-mips <linux-mips@linux-mips.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:48442 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbZKJJUU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 04:20:20 -0500
Received: by bwz27 with SMTP id 27so4318162bwz.21
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 01:20:25 -0800 (PST)
In-Reply-To: <200911100113.38685.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Tue, Nov 10, 2009 at 1:13 AM, Florian Fainelli <florian@openwrt.org>=
 wrote:
> This patch converts the au1000-eth driver to become a full
> platform-driver as it ought to be. We now pass PHY-speficic
> configurations through platform_data but for compatibility
> the driver still assumes the default settings (search for PHY1 on
> MAC0) when no platform_data is passed. Tested on my MTX-1 board.
>
> Acked-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---
> diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
> index ce6f1ac..6d5a2cb 100644
> --- a/drivers/net/au1000_eth.c
> +++ b/drivers/net/au1000_eth.c

> -# if defined(AU1XXX_PHY1_SEARCH_ON_MAC0)
> - =A0 =A0 =A0 /* try harder to find a PHY */
> - =A0 =A0 =A0 if (!phydev && (aup->mac_id =3D=3D 1)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* no PHY found, maybe we have a dual P=
HY? */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk (KERN_INFO DRV_NAME ": no PHY fo=
und on MAC1, "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "let's see if it's atta=
ched to MAC0...\n");
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!au_macs[0]);


> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* find the first (lowest address) non-=
attached PHY on
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the MAC0 MII bus */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (phy_addr =3D 0; phy_addr < PHY_MAX=
_ADDR; phy_addr++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct phy_device *cons=
t tmp_phydev =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 au_macs=
[0]->mii_bus->phy_map[phy_addr];
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!tmp_phydev)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e; /* no PHY here... */
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tmp_phydev->attache=
d_dev)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e; /* already claimed by MAC0 */
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int phy_addr;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* find the first (lowest address) PHY =
on the current MAC's MII bus */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (phy_addr =3D 0; phy_addr < PHY_MAX=
_ADDR; phy_addr++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (aup->mii_bus->phy_m=
ap[phy_addr]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phydev =
=3D aup->mii_bus->phy_map[phy_addr];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!au=
p->phy_search_highest_addr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 break; /* break out with first one found */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phydev =3D tmp_phydev;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break; /* found it */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (aup->phy1_search_mac0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* try harder to find a=
 PHY */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!phydev && (aup->ma=
c_id =3D=3D 1)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* no P=
HY found, maybe we have a dual PHY? */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk =
(KERN_INFO DRV_NAME ": no PHY found on MAC1, "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "let's see if it's attached to MAC0...\n");
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* find=
 the first (lowest address) non-attached PHY on
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* th=
e MAC0 MII bus */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (ph=
y_addr =3D 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 if (aup->mac_id =3D=3D 1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 break;

aup->mac_id needs to be 1 for this loop to be executed in the first
place, and here
you immediately bail out if it is.
Also, how do you access the phy map of the other controller without use=
 of the
au_macs[] structure? (which is unused after this patch and could be
removed, along
with the NUM_ETH_INTERFACES constant)


> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 struct phy_device *const tmp_phydev =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 aup->mii_bus->phy_map[phy_addr=
];

My compiler complains about mixed code/declarations.


Thanks!
      Manuel Lauss
