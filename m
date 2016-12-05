From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH V2 net 13/20] net/ena: change driver's default timeouts
Date: Sun, 4 Dec 2016 20:35:24 -0800
Message-ID: <20161205043524.GJ4310@u54ee753d2d1854bda401.ant.amazon.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
 <1480857578-5065-14-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <dwmw@amazon.com>,
        <zorik@annapurnalabs.com>, <alex@annapurnalabs.com>,
        <saeed@annapurnalabs.com>, <msw@amazon.com>, <aliguori@amazon.com>,
        <nafea@annapurnalabs.com>
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1480857578-5065-14-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 04, 2016 at 03:19:31PM +0200, Netanel Belgazal wrote:

... because? (they turned out to be too aggressive, I believe.)

> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> ---
>  drivers/net/ethernet/amazon/ena/ena_com.c    | 4 ++--
>  drivers/net/ethernet/amazon/ena/ena_netdev.h | 7 ++++---
>  2 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
> index 4147d6e..a550c8a 100644
> --- a/drivers/net/ethernet/amazon/ena/ena_com.c
> +++ b/drivers/net/ethernet/amazon/ena/ena_com.c
> @@ -36,9 +36,9 @@
>  /*****************************************************************************/
>  
>  /* Timeout in micro-sec */
> -#define ADMIN_CMD_TIMEOUT_US (1000000)
> +#define ADMIN_CMD_TIMEOUT_US (3000000)
>  
> -#define ENA_ASYNC_QUEUE_DEPTH 4
> +#define ENA_ASYNC_QUEUE_DEPTH 16

Why is this changed at the same time?

>  #define ENA_ADMIN_QUEUE_DEPTH 32
>  
>  #define MIN_ENA_VER (((ENA_COMMON_SPEC_VERSION_MAJOR) << \
> diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
> index c081fd3..ed42e07 100644
> --- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
> +++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
> @@ -39,6 +39,7 @@
>  #include <linux/interrupt.h>
>  #include <linux/netdevice.h>
>  #include <linux/skbuff.h>
> +#include <linux/u64_stats_sync.h>

This change seems unrelated.

>  #include "ena_com.h"
>  #include "ena_eth_com.h"
> @@ -100,7 +101,7 @@
>  /* Number of queues to check for missing queues per timer service */
>  #define ENA_MONITORED_TX_QUEUES	4
>  /* Max timeout packets before device reset */
> -#define MAX_NUM_OF_TIMEOUTED_PACKETS 32
> +#define MAX_NUM_OF_TIMEOUTED_PACKETS 128
>  
>  #define ENA_TX_RING_IDX_NEXT(idx, ring_size) (((idx) + 1) & ((ring_size) - 1))
>  
> @@ -116,9 +117,9 @@
>  #define ENA_IO_IRQ_IDX(q)		(ENA_IO_IRQ_FIRST_IDX + (q))
>  
>  /* ENA device should send keep alive msg every 1 sec.
> - * We wait for 3 sec just to be on the safe side.
> + * We wait for 6 sec just to be on the safe side.
>   */
> -#define ENA_DEVICE_KALIVE_TIMEOUT	(3 * HZ)
> +#define ENA_DEVICE_KALIVE_TIMEOUT	(6 * HZ)
>  
>  #define ENA_MMIO_DISABLE_REG_READ	BIT(0)
>  
