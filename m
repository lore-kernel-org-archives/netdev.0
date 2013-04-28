From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH] sh_eth: use random MAC address if no valid one supplied
Date: Sun, 28 Apr 2013 22:29:09 +0200
Message-ID: <1405436.hE5aNhyzLb@avalon>
References: <201304280248.11893.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perceval.ideasonboard.com ([95.142.166.194]:46016 "EHLO
	perceval.ideasonboard.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756316Ab3D1U3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 16:29:05 -0400
In-Reply-To: <201304280248.11893.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

Thank you for the patch.

On Sunday 28 April 2013 02:48:11 Sergei Shtylyov wrote:
> On Renesas R-Car based development boards, although a MAC address is printed
> on all the Ethernet port labels, U-Boot  doesn't write a valid MAC address 
> to the Ether MAHR/MALR registers (there's no storage provided for the Ether
> MAC address either), so we have to resort to using a random MAC address...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> This patch is against the 'net-next.git' repository.
> 
>  drivers/net/ethernet/renesas/sh_eth.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
> ===================================================================
> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net-next/drivers/net/ethernet/renesas/sh_eth.c
> @@ -2735,6 +2735,11 @@ static int sh_eth_drv_probe(struct platf
> 
>  	/* read and set MAC address */
>  	read_mac_address(ndev, pd->mac_addr);
> +	if (!is_valid_ether_addr(ndev->dev_addr)) {
> +		dev_warn(&pdev->dev, "no valid MAC address supplied, using "
> +			 "a random one.\n");

Breaking log messages in the middle of a line is frowned upon, more than 
exceeding the 80 characters per line (soft) limit. I think

        dev_warn(&pdev->dev,
                 "no valid MAC address supplied, using a random one.\n");

would be better.

> +		eth_hw_addr_random(ndev);
> +	}
> 
>  	/* ioremap the TSU registers */
>  	if (mdp->cd->tsu) {

-- 
Regards,

Laurent Pinchart
