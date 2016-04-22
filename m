From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next] hv_netvsc: Fix the list processing for network
 change event
Date: Fri, 22 Apr 2016 10:49:19 +0200
Message-ID: <87y486yqnk.fsf@vitty.brq.redhat.com>
References: <1461280381-17530-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 davem@davemloft.net
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1461280381-17530-1-git-send-email-haiyangz@microsoft.com>
 (Haiyang Zhang's message of "Thu, 21 Apr 2016 16:13:01 -0700")
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Haiyang Zhang <haiyangz@microsoft.com> writes:

> RNDIS_STATUS_NETWORK_CHANGE event is handled as two "half events" --
> media disconnect & connect. The second half should be added to the list
> head, not to the tail. So all events are processed in normal order.
>

Thanks,

this matters when we get some other events in between these two halves.

Reviewed-by: Vitaly Kuznetsov <vkuznets@redhat.com>

> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index bfdb568a..ba3f3f3 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -1125,7 +1125,7 @@ static void netvsc_link_change(struct work_struct *w)
>  			netif_tx_stop_all_queues(net);
>  			event->event = RNDIS_STATUS_MEDIA_CONNECT;
>  			spin_lock_irqsave(&ndev_ctx->lock, flags);
> -			list_add_tail(&event->list, &ndev_ctx->reconfig_events);
> +			list_add(&event->list, &ndev_ctx->reconfig_events);
>  			spin_unlock_irqrestore(&ndev_ctx->lock, flags);
>  			reschedule = true;
>  		}

-- 
  Vitaly
