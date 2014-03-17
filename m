From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v2,1/1] hyperv: Add support for virtual
 Receive Side Scaling (vRSS)
Date: Mon, 17 Mar 2014 16:19:55 -0400 (EDT)
Message-ID: <20140317.161955.776021754942208577.davem@davemloft.net>
References: <1394903887-30421-1-git-send-email-haiyangz@microsoft.com>
 <1394903887-30421-2-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394903887-30421-2-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Sat, 15 Mar 2014 10:18:07 -0700

> -		if (netif_queue_stopped(ndev) && !net_device->start_remove &&
> -			(hv_ringbuf_avail_percent(&device->channel->outbound)
> -			> RING_AVAIL_PERCENT_HIWATER ||
> -			num_outstanding_sends < 1))
> -				netif_wake_queue(ndev);
> +		if (netif_tx_queue_stopped(netdev_get_tx_queue(ndev, q_idx))
> +			&& !net_device->start_remove &&
> +			(hv_ringbuf_avail_percent(&channel->outbound)
> +			> RING_AVAIL_PERCENT_HIWATER || queue_sends < 1))
> +				netif_tx_wake_queue(netdev_get_tx_queue(
> +						    ndev, q_idx));

This is not indented properly, make it:

	if (A && B &&
	    (C >
             D || E < 1))

Never put operators at the beginning of a conditional line, always at
the end.
