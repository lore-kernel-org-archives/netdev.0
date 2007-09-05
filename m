From: Jesse Huang <jesse@icplus.com.tw>
Subject: Re: [patch 02/18] sundance: PHY address form 0, only for device I
	D 0x0200 (IP100A) (20070605)
Date: Wed, 05 Sep 2007 14:39:48 -0400
Message-ID: <1189017588.6670.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: jeff@garzik.org, akpm@linux-foundation.org, netdev@vger.kernel.org,
	jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr36.hinet.net ([168.95.4.136]:45249 "EHLO msr36.hinet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328AbXIEGoy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 02:44:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Jeff:
We found current sundance.c in kernel 2.6.22 is working fine for IP100A=
=2E
We need not to modify following codes:
> -       for (phy =3D 1; phy <=3D 32 && phy_idx < MII_CNT; phy++) {
> +       if (sundance_pci_tbl[np->chip_id].device =3D=3D 0x0200)
> +               phy =3D 0;
> +       else
> +               phy =3D 1;
> +       for (; phy <=3D 32 && phy_idx < MII_CNT; phy++) {


Current code will find IP100A at 0 when phy was equ to 32.
for (phy =3D 1; phy <=3D 32 && phy_idx < MII_CNT; phy++) {
		int phyx =3D phy & 0x1f;
		int mii_status =3D mdio_read(dev, phyx, MII_BMSR);
		if (mii_status !=3D 0xffff  &&  mii_status !=3D 0x0000) {
			np->phys[phy_idx++] =3D phyx;
			np->mii_if.advertising =3D mdio_read(dev, phyx, MII_ADVERTISE);
			if ((mii_status & 0x0040) =3D=3D 0)
				np->mii_preamble_required++;
			printk(KERN_INFO "%s: MII PHY found at address %d, status "
				   "0x%4.4x advertising %4.4x.\n",
				   dev->name, phyx, mii_status, np->mii_if.advertising);
		}
	}

So, we hope you can drop this patch "[patch 02/18] sundance: PHY addres=
s
form 0, only for device I D 0x0200 (IP100A) (20070605)"

Thanks a lot!

Best Regards,
Jesse Huang

-----Original Message-----
=46rom: Jeff Garzik [mailto:jeff@garzik.org]=20
Sent: Monday, September 03, 2007 6:43 PM
To: =C2=B6=C3=80=C2=AB=C3=98=C2=BF=C2=B3-Jesse
Cc: akpm@linux-foundation.org; netdev@vger.kernel.org
Subject: Re: [patch 02/18] sundance: PHY address form 0, only for devic=
e
I D 0x0200 (IP100A) (20070605)

=C2=B6=C3=80=C2=AB=C3=98=C2=BF=C2=B3-Jesse wrote:
> +++ a/drivers/net/sundance.c
> @@ -559,7 +559,11 @@ static int __devinit sundance_probe1 (st
>          * It seems some phys doesn't deal well with address 0 being
> accessed
>          * first, so leave address zero to the end of the loop (32 &
31).
>          */
> -       for (phy =3D 1; phy <=3D 32 && phy_idx < MII_CNT; phy++) {
> +       if (sundance_pci_tbl[np->chip_id].device =3D=3D 0x0200)
> +               phy =3D 0;
> +       else
> +               phy =3D 1;
> +       for (; phy <=3D 32 && phy_idx < MII_CNT; phy++) {


As I noted in the last email, this patch still has a bug:

In the above loop code being modified, you need to change two things:

1) Initial loop value
2) Loop terminating condition

Your patch only performs change #1.

	Jeff



