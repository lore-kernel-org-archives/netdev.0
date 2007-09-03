From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 02/18] sundance: PHY address form 0, only for device I
 D 0x0200 (IP100A) (20070605)
Date: Mon, 03 Sep 2007 06:42:50 -0400
Message-ID: <46DBE52A.2010207@garzik.org>
References: <AA68EB0EBA29BA40A06B700C33343EEF018686BB@fileserver.icplus.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: =?UTF-8?B?6buD5bu66IiILUplc3Nl?= <Jesse@icplus.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50298 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754249AbXICKm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2007 06:42:58 -0400
In-Reply-To: <AA68EB0EBA29BA40A06B700C33343EEF018686BB@fileserver.icplus.com.tw>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E9=BB=83=E5=BB=BA=E8=88=88-Jesse wrote:
> +++ a/drivers/net/sundance.c
> @@ -559,7 +559,11 @@ static int __devinit sundance_probe1 (st
>          * It seems some phys doesn't deal well with address 0 being=20
> accessed
>          * first, so leave address zero to the end of the loop (32 & =
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


