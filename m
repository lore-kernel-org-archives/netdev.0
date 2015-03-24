From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] ucc_geth: Intialize link state to down before register_netdev
Date: Tue, 24 Mar 2015 20:30:00 +0100
Message-ID: <5511BB38.8010501@gmx.de>
References: <OF515B2C92.39F94674-ON88257E12.00676FA3-88257E12.00679D6B@selinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cliff_clark@selinc.com, Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:65112 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752948AbbCXTaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 15:30:12 -0400
In-Reply-To: <OF515B2C92.39F94674-ON88257E12.00676FA3-88257E12.00679D6B@selinc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24.03.2015 19:51, cliff_clark@selinc.com wrote:
> ucc_geth was indicating link up after a port is administratively enabled 
> even
> when nothing is plugged in.  This causes user-space tools to see a 
> spurious link
> up the first time after boot.
> 
> Signed-off-by: Cliff Clark <cliff_clark@selinc.com>
> ---
>  drivers/net/ethernet/freescale/ucc_geth.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/ethernet/freescale/ucc_geth.c 
> b/drivers/net/ethernet/freescale/ucc_geth.c
> index 357e8b57..56b774d 100644
> --- a/drivers/net/ethernet/freescale/ucc_geth.c
> +++ b/drivers/net/ethernet/freescale/ucc_geth.c
> @@ -3893,6 +3893,9 @@ static int ucc_geth_probe(struct platform_device* 
> ofdev)
>         ugeth->phy_interface = phy_interface;
>         ugeth->max_speed = max_speed;
>  
> +       /* Carrier starts down, phylib will bring it up */
> +       netif_carrier_off(dev);
> +
>         err = register_netdev(dev);
>         if (err) {
>                 if (netif_msg_probe(ugeth))

The commit message is still messy. checkpatch also complaints about
spaces at the beginning of a line.

Regards,
Lino
