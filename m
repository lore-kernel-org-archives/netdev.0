From: Sony Chacko <sony.chacko@qlogic.com>
Subject: RE: [PATCH] qlcnic: constify qlcnic_mbx_ops structure
Date: Tue, 13 Oct 2015 03:40:46 +0000
Message-ID: <0EA5B226BC5C7B45A71BF612AA8A019E01948A96D7@AVMB1.qlogic.org>
References: <1444564085-12839-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444564085-12839-1-git-send-email-Julia.Lawall@lip6.fr>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-
> owner@vger.kernel.org] On Behalf Of Julia Lawall
> Sent: Sunday, October 11, 2015 4:48 AM
> To: Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>
> Cc: kernel-janitors@vger.kernel.org; netdev <netdev@vger.kernel.org>; linux-
> kernel <linux-kernel@vger.kernel.org>
> Subject: [PATCH] qlcnic: constify qlcnic_mbx_ops structure
> 
> The only instance of a qlcnic_mbx_ops structure is never modified.  Thus the
> declaration of the structure and all references to the structure type can be made
> const.
> 
> In the definition of the qlcnic_mailbox structure, the ops field is no longer lined
> up with the other fields.  This was left as is, to avoid a lot of trivial changes on
> the other lines.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic.h         |    2 +-
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c |    4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
> index 9f0bdd9..37a731b 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
> @@ -4048,7 +4048,7 @@ static void qlcnic_83xx_mailbox_worker(struct
> work_struct *work)
>  	struct qlcnic_mailbox *mbx = container_of(work, struct qlcnic_mailbox,
>  						  work);
>  	struct qlcnic_adapter *adapter = mbx->adapter;
> -	struct qlcnic_mbx_ops *mbx_ops = mbx->ops;
> +	const struct qlcnic_mbx_ops *mbx_ops = mbx->ops;
>  	struct device *dev = &adapter->pdev->dev;
>  	atomic_t *rsp_status = &mbx->rsp_status;
>  	struct list_head *head = &mbx->cmd_q;
> @@ -4098,7 +4098,7 @@ static void qlcnic_83xx_mailbox_worker(struct
> work_struct *work)
>  	}
>  }
> 
> -static struct qlcnic_mbx_ops qlcnic_83xx_mbx_ops = {
> +static const struct qlcnic_mbx_ops qlcnic_83xx_mbx_ops = {
>  	.enqueue_cmd    = qlcnic_83xx_enqueue_mbx_cmd,
>  	.dequeue_cmd    = qlcnic_83xx_dequeue_mbx_cmd,
>  	.decode_resp    = qlcnic_83xx_decode_mbx_rsp,
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> index d6696cf..46bbea8 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> @@ -1092,7 +1092,7 @@ struct qlcnic_filter_hash {  struct qlcnic_mailbox {
>  	struct workqueue_struct	*work_q;
>  	struct qlcnic_adapter	*adapter;
> -	struct qlcnic_mbx_ops	*ops;
> +	const struct qlcnic_mbx_ops *ops;
>  	struct work_struct	work;
>  	struct completion	completion;
>  	struct list_head	cmd_q;
> 
Acked-by: Sony Chacko <sony.chacko@qlogic.com>

Thanks,
Sony
