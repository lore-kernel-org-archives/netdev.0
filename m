From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH] net: fjes: fjes_main: Remove create_workqueue
Date: Thu, 2 Jun 2016 23:55:19 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A7351D7C4@G01JPEXMBYT01>
References: <20160602093057.GA15351@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: Tejun Heo <tj@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160602093057.GA15351@Karyakshetra>
Content-Language: ja-JP
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Bhaktipriya,

Thanks. Looks good to me.

Sincerely,
Taku Izumi

> -----Original Message-----
> From: Bhaktipriya Shridhar [mailto:bhaktipriya96@gmail.com]
> Sent: Thursday, June 02, 2016 6:31 PM
> To: David S. Miller; Izumi, Taku/泉 拓; Florian Westphal; Bhaktipriya Shridhar
> Cc: Tejun Heo; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH] net: fjes: fjes_main: Remove create_workqueue
> 
> alloc_workqueue replaces deprecated create_workqueue().
> 
> The workqueue adapter->txrx_wq has workitem
> &adapter->raise_intr_rxdata_task per adapter. Extended Socket Network
> Device is shared memory based, so someone's transmission denotes other's
> reception.  raise_intr_rxdata_task raises interruption of receivers from
> the sender in order to notify receivers.
> 
> The workqueue adapter->control_wq has workitem
> &adapter->interrupt_watch_task per adapter. interrupt_watch_task is used
> to prevent delay of interrupts.
> 
> Dedicated workqueues have been used in both cases since the workitems
> on the workqueues are involved in normal device operation and require
> forward progress under memory pressure.
> 
> max_active has been set to 0 since there is no need for throttling
> the number of active work items.
> 
> Since network devices  may be used for memory reclaim,
> WQ_MEM_RECLAIM has been set to guarantee forward progress.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
> ---
>  drivers/net/fjes/fjes_main.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
> index 86c331b..9006877 100644
> --- a/drivers/net/fjes/fjes_main.c
> +++ b/drivers/net/fjes/fjes_main.c
> @@ -1187,8 +1187,9 @@ static int fjes_probe(struct platform_device *plat_dev)
>  	adapter->force_reset = false;
>  	adapter->open_guard = false;
> 
> -	adapter->txrx_wq = create_workqueue(DRV_NAME "/txrx");
> -	adapter->control_wq = create_workqueue(DRV_NAME "/control");
> +	adapter->txrx_wq = alloc_workqueue(DRV_NAME "/txrx", WQ_MEM_RECLAIM, 0);
> +	adapter->control_wq = alloc_workqueue(DRV_NAME "/control",
> +					      WQ_MEM_RECLAIM, 0);
> 
>  	INIT_WORK(&adapter->tx_stall_task, fjes_tx_stall_task);
>  	INIT_WORK(&adapter->raise_intr_rxdata_task,
> --
> 2.1.4
> 
