From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next-2.6] bnx2: remove cancel_work_sync() from
 remove_one
Date: Tue, 14 Dec 2010 09:48:00 -0800
Message-ID: <1292348880.7394.63.camel@nseg_linux_HP1.broadcom.com>
References: <4D0796D7.3030309@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: "Tejun Heo" <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D0796D7.3030309@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2010-12-14 at 08:09 -0800, Tejun Heo wrote:
> Michael pointed out that bnx2_close() already cancels bp->reset_task
> and thus it is guaranteed to be idle when bnx2_remove_one() is called.
> Remove the unnecessary cancel_work_sync() in remove_one.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Michael Chan <mchan@broadcom.com>

Acked-by: Michael Chan <mchan@broadcom.com>

> ---
>  drivers/net/bnx2.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 5c811f3..85fc2c8 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -8393,8 +8393,6 @@ bnx2_remove_one(struct pci_dev *pdev)
>  	struct net_device *dev = pci_get_drvdata(pdev);
>  	struct bnx2 *bp = netdev_priv(dev);
> 
> -	cancel_work_sync(&bp->reset_task);
> -
>  	unregister_netdev(dev);
> 
>  	if (bp->mips_firmware)
> 
