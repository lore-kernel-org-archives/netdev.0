From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH/RFC] [POWERPC] Add fixed-phy support for fs_enet
Date: Mon, 17 Dec 2007 18:20:14 -0500
Message-ID: <4767042E.2070903@garzik.org>
References: <47601027.2080104@scram.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vitaly Bordug <vitb@kernel.crashing.org>, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Scott Wood <scottwood@freescale.com>
To: Jochen Friedrich <jochen@scram.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48974 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754234AbXLQXUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 18:20:21 -0500
In-Reply-To: <47601027.2080104@scram.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jochen Friedrich wrote:
> This patch adds support to use the fixed-link property
> of an ethernet node to fs_enet for the
> CONFIG_PPC_CPM_NEW_BINDING case.
> 
> Signed-off-by: Jochen Friedrich <jochen@scram.de>
> ---
>  drivers/net/fs_enet/fs_enet-main.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
> index f2a4d39..8220c70 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -1174,8 +1174,15 @@ static int __devinit find_phy(struct device_node *np,
>  	struct device_node *phynode, *mdionode;
>  	struct resource res;
>  	int ret = 0, len;
> +	const u32 *data;
> +
> +	data  = of_get_property(np, "fixed-link", NULL);
> +	if (data) {
> +		snprintf(fpi->bus_id, 16, PHY_ID_FMT, 0, *data);
> +		return 0;
> +	}
> 
> -	const u32 *data = of_get_property(np, "phy-handle", &len);
> +	data = of_get_property(np, "phy-handle", &len);
>  	if (!data || len != 4)

ACK, pass this through paulus?


