From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net 6/6] bnx2x: Fix ethtool advertisement
Date: Tue, 06 Sep 2011 16:19:52 +0100
Message-ID: <1315322392.2788.2.camel@bwh-desktop>
References: <1315291645.28564.20.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eilong@broadcom.com, netdev@vger.kernel.org
To: Yaniv Rosner <yanivr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37732 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114Ab1IFPT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 11:19:56 -0400
In-Reply-To: <1315291645.28564.20.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-06 at 09:47 +0300, Yaniv Rosner wrote:
> Enable changing advertisement settings via ethtool and fix
> flow-control advertisement when autoneg flow-control is disabled.
[...]
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
> index f74582a..42c7be1 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -2125,6 +2125,12 @@ static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
>  void bnx2x_calc_fc_adv(struct bnx2x *bp)
>  {
>  	u8 cfg_idx = bnx2x_get_link_cfg_idx(bp);
> +	if (bp->link_params.req_flow_ctrl[cfg_idx] != BNX2X_FLOW_CTRL_AUTO) {
> +		bp->port.advertising[cfg_idx] &= ~(ADVERTISED_Asym_Pause |
> +						   ADVERTISED_Pause);
> +		return;
> +	}
[...]

I think you should still advertise the flow control behaviour you want,
even if you will override the result of autonegotiation.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
