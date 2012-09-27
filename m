From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH] net: ti cpsw ethernet: set IFCTL_A bit in MACCONTROL
Date: Thu, 27 Sep 2012 18:40:13 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9EC49D@DBDE01.ent.ti.com>
References: <1348746636-24156-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Hiremath, Vaibhav" <hvaibhav@ti.com>,
	"David S. Miller" <davem@davemloft.net>
To: Daniel Mack <zonque@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:37945 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704Ab2I0SkV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 14:40:21 -0400
In-Reply-To: <1348746636-24156-1-git-send-email-zonque@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Daniel Mack [mailto:zonque@gmail.com]
> Sent: Thursday, September 27, 2012 5:21 PM
> To: netdev@vger.kernel.org
> Cc: Daniel Mack; N, Mugunthan V; Hiremath, Vaibhav; David S. Miller
> Subject: [PATCH] net: ti cpsw ethernet: set IFCTL_A bit in MACCONTROL
> 
> For RMII/RGMII mode operation in 100Mbps, the CPSW needs to set the
> IFCTL_A bits in the MACCONTROL register. For all other PHY modes, this
> bit is unused, so setting it unconditionally shouldn't cause any
> trouble.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Cc: Vaibhav Hiremath <hvaibhav@ti.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c
> b/drivers/net/ethernet/ti/cpsw.c
> index aa78168..b764f75 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -386,6 +386,11 @@ static void _cpsw_adjust_link(struct cpsw_slave
> *slave,
>  			mac_control |= BIT(7);	/* GIGABITEN	*/
>  		if (phy->duplex)
>  			mac_control |= BIT(0);	/* FULLDUPLEXEN	*/
> +
> +		/* set speed_in input in case RMII mode is used in >10Mbps
> */
> +		if (phy->speed > 10)

Please change the speed check as == 100 as it is required only for 100Mbps link

Regards
Mugunthan V N

> +			mac_control |= BIT(15);
> +
>  		*link = true;
>  	} else {
>  		mac_control = 0;
> --
> 1.7.11.4
