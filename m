From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] r8152: check the status before submitting
 rx
Date: Fri, 19 Dec 2014 15:44:02 -0500 (EST)
Message-ID: <20141219.154402.54691026682141762.davem@davemloft.net>
References: <1394712342-15778-107-Taiwan-albertk@realtek.com>
	<1394712342-15778-109-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-109-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 19 Dec 2014 16:56:00 +0800

> Don't submit the rx if the device is unplugged, linking down,
> or stopped.
 ...
> @@ -1789,6 +1789,11 @@ int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags)
>  {
>  	int ret;
>  
> +	/* The rx would be stopped, so skip submitting */
> +	if (test_bit(RTL8152_UNPLUG, &tp->flags) ||
> +	    !test_bit(WORK_ENABLE, &tp->flags) || !(tp->speed & LINK_STATUS))
> +		return 0;
> +

I think netif_carrier_off() should always be true in all three of those
situations, and would be a much simpler test than what you've coded
here.
