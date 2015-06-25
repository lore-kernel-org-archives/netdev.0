From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 6/9] bnx2x: Fix self-test for 20g devices
Date: Thu, 25 Jun 2015 16:46:41 +0300
Message-ID: <558C0641.4000904@cogentembedded.com>
References: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com> <1435234769-5625-7-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariel.Elior@qlogic.com
To: Yuval Mintz <Yuval.Mintz@qlogic.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:35472 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbbFYNqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 09:46:46 -0400
Received: by lagi2 with SMTP id i2so45435648lag.2
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 06:46:44 -0700 (PDT)
In-Reply-To: <1435234769-5625-7-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/25/2015 03:19 PM, Yuval Mintz wrote:

> 20g-capable devices are not configured properly for self-test, using
> 10g as their speed which cause the link indication to remain down and
> fail the internal loopback test.

> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
> ---
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 12 ++++++++----
>   1 file changed, 8 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index c1033a5..3df03bb 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -2347,12 +2347,16 @@ int bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
>   		if (load_mode == LOAD_DIAG) {
>   			struct link_params *lp = &bp->link_params;
>   			lp->loopback_mode = LOOPBACK_XGXS;
> -			/* do PHY loopback at 10G speed, if possible */
> -			if (lp->req_line_speed[cfx_idx] < SPEED_10000) {
> +			/* Prefer doing PHY loopback at highest speed */
> +			if (lp->req_line_speed[cfx_idx] < SPEED_20000) {
>   				if (lp->speed_cap_mask[cfx_idx] &
> -				    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
> +				    PORT_HW_CFG_SPEED_CAPABILITY_D0_20G)
>   					lp->req_line_speed[cfx_idx] =
> -					SPEED_10000;
> +					SPEED_20000;

    I would have added one more tab here.

> +				else if (lp->speed_cap_mask[cfx_idx] &
> +					    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)

    This line should have been started right under 'lp'.

> +						lp->req_line_speed[cfx_idx] =

    This line is indented too much.

> +						SPEED_10000;

    This line seems alright.

WBR, Sergei
