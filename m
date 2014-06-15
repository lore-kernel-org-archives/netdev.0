From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Missing return check against Null for return value of
 netdev_alloc_dev_skb()
Date: Sat, 14 Jun 2014 23:53:00 -0700 (PDT)
Message-ID: <20140614.235300.1228145928404410306.davem@davemloft.net>
References: <1402805139-6363-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andriy.shevchenko@linux.intel.com, dvhart@linux.intel.com,
	jeffrey.t.kirsher@intel.com, ast@plumgrid.com, dborkman@redhat.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xerofoify@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402805139-6363-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nick <xerofoify@gmail.com>
Date: Sun, 15 Jun 2014 00:05:39 -0400

> Signed-off-by: Nick <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> index 73e6683..704cf63 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -1515,6 +1515,8 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
>  	for (i = 0; i < tx_ring->count; i++) {
>  		buffer_info = &tx_ring->buffer_info[i];
>  		skb = netdev_alloc_skb(adapter->netdev, bufsz);
> +		if (!skb)
> +			return NULL;

You didn't even compile test this.

The function has a void return type, you can't return NULL.

Furthermore, you have to adjust things so that the caller knows that
this operation failed, because the device cannot be brought up
successfully unless all the TX buffer slots get allocated properly.
