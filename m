From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 3/4] bnx2: Report MDI/MDIX status to ethtool.
Date: Wed, 1 Jan 2014 16:24:58 +0000
Message-ID: <1388593498.6642.11.camel@deadeye.wl.decadent.org.uk>
References: <1388560955-32586-1-git-send-email-mchan@broadcom.com>
	 <1388560955-32586-2-git-send-email-mchan@broadcom.com>
	 <1388560955-32586-3-git-send-email-mchan@broadcom.com>
	 <1388560955-32586-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48324 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753604AbaAAQZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 11:25:06 -0500
In-Reply-To: <1388560955-32586-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-31 at 23:22 -0800, Michael Chan wrote:
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2.c |   16 ++++++++++++++++
>  drivers/net/ethernet/broadcom/bnx2.h |    4 ++++
>  2 files changed, 20 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> index b380c69..3fcabd9 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
[...]
> @@ -6874,6 +6884,12 @@ bnx2_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  	if (netif_carrier_ok(dev)) {
>  		ethtool_cmd_speed_set(cmd, bp->line_speed);
>  		cmd->duplex = bp->duplex;
> +		if (!(bp->phy_flags & BNX2_PHY_FLAG_SERDES)) {
> +			if (bp->phy_flags & BNX2_PHY_FLAG_MDIX)
> +				cmd->eth_tp_mdix = ETH_TP_MDI_X;
> +			else
> +				cmd->eth_tp_mdix = ETH_TP_MDI;
> +		}
[...]

You could also set cmd->eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO to show that
auto-MDI-X is supported.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
