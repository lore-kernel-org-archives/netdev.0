From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Subject: RE: [PATCH V2 1/2] bnx2x: Adapter not recovery from EEH error
 injection
Date: Fri, 30 May 2014 12:32:54 +0000
Message-ID: <87B4DDAD5EAFA041BDC28F314593782D0174AA27@avmb3.qlogic.org>
References: <20140528155641.920171803@linux.vnet.ibm.com>
 <20140528155722.190598661@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: "wenxiong@linux.vnet.ibm.com" <wenxiong@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:27443 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751115AbaE3MdA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2014 08:33:00 -0400
In-Reply-To: <20140528155722.190598661@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of wenxiong@linux.vnet.ibm.com
> Sent: Wednesday, May 28, 2014 6:57 PM
> To: David Miller
> Cc: Ariel Elior; netdev; Wen Xiong
> Subject: [PATCH V2 1/2] bnx2x: Adapter not recovery from EEH error
> injection
>
> When injecting EEH error to bnx2x adapter, adapter couldn't be recovery
> and caused recursive EEH errors. The patch fixes the issue.
>
> Signed-off-by: Wen Xiong <wenxiong@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> Index: b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> ===================================================================
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c        2014-05-22
> 18:42:48.000000000 -0500
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c        2014-05-22
> 18:44:36.757765539 -0500
> @@ -13279,8 +13279,8 @@ static int bnx2x_eeh_nic_unload(struct b
>       netdev_reset_tc(bp->dev);
>
>       del_timer_sync(&bp->timer);
> -     cancel_delayed_work(&bp->sp_task);
> -     cancel_delayed_work(&bp->period_task);
> +     cancel_delayed_work_sync(&bp->sp_task);
> +     cancel_delayed_work_sync(&bp->period_task);
>
>       spin_lock_bh(&bp->stats_lock);
>       bp->stats_state = STATS_STATE_DISABLED;
>

Thanks.

Reviewed-by: Dmitry Kravkov <dmitry.kravkov@qlogic.com>

> --
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
