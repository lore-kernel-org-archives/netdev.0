From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH net-next-2.6] vxge: add missing flush of reset_task
Date: Wed, 15 Dec 2010 08:29:00 -0600
Message-ID: <20101215142859.GA13516@exar.com>
References: <4D08CAB1.6040402@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D08CAB1.6040402@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 15, 2010 at 06:03:29AM -0800, Tejun Heo wrote:
> Commit 6e07ebd84 (drivers/net: remove unnecessary
> flush_scheduled_work() calls) incorrectly removed the flush call
> without replacing it with the appropriate work specific operation.
> Fix it by flushing vdev->reset_task explicitly.
> 
> Pointed out by Jon Mason.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jon Mason <jon.mason@exar.com>
Acked-by: Jon Mason <jon.mason@exar.com>
> ---
>  drivers/net/vxge/vxge-main.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
> index 537ad87..1ac9b56 100644
> --- a/drivers/net/vxge/vxge-main.c
> +++ b/drivers/net/vxge/vxge-main.c
> @@ -3439,6 +3439,8 @@ static void vxge_device_unregister(struct __vxge_hw_device *hldev)
> 
>  	strncpy(buf, dev->name, IFNAMSIZ);
> 
> +	flush_work_sync(&vdev->reset_task);
> +
>  	/* in 2.6 will call stop() if device is up */
>  	unregister_netdev(dev);
> 
