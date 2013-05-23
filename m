From: Richard Genoud <richard.genoud@gmail.com>
Subject: Re: [PATCH net, 1/2] hyperv: Fix a kernel warning from netvsc_linkstatus_callback()
Date: Thu, 23 May 2013 10:44:18 +0200
Message-ID: <CACQ1gAi0JfJFAc822YT5xVfW8HkB8r_4rf0dXTNsi-1oChsPsQ@mail.gmail.com>
References: <1365198280-23270-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365198280-23270-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/4/5 Haiyang Zhang <haiyangz@microsoft.com>:
> The warning about local_bh_enable inside IRQ happens when disconnecting a
> virtual NIC.
>
> The reason for the warning is -- netif_tx_disable() is called when the NIC
> is disconnected. And it's called within irq context. netif_tx_disable() calls
> local_bh_enable() which displays warning if in irq.
>
> The fix is to remove the unnecessary netif_tx_disable & wake_queue() in the
> netvsc_linkstatus_callback().
>
> Reported-by: Richard Genoud <richard.genoud@gmail.com>
> Tested-by: Long Li <longli@microsoft.com>
> Tested-by: Richard Genoud <richard.genoud@gmail.com>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
>
> ---
>  drivers/net/hyperv/netvsc_drv.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 5f85205..8341b62 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -241,13 +241,11 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
>
>         if (status == 1) {
>                 netif_carrier_on(net);
> -               netif_wake_queue(net);
>                 ndev_ctx = netdev_priv(net);
>                 schedule_delayed_work(&ndev_ctx->dwork, 0);
>                 schedule_delayed_work(&ndev_ctx->dwork, msecs_to_jiffies(20));
>         } else {
>                 netif_carrier_off(net);
> -               netif_tx_disable(net);
>         }
>  }
>
> --
> 1.7.4.1

This should also go to the stable tree, shouldn't it ?
At least 3.8, 3.7 and 3.4 (the 3.2 version is different, and it's in
staging. (at not used by distros anyway))


Richard.
