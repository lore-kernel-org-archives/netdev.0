From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] r8152: reduce the number of Tx
Date: Fri, 29 Aug 2014 20:25:04 -0700 (PDT)
Message-ID: <20140829.202504.655684636693672249.davem@davemloft.net>
References: <1394712342-15778-23-Taiwan-albertk@realtek.com>
	<1394712342-15778-24-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-24-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 28 Aug 2014 10:24:18 +0800

> Because the Tx has the features of stopping queue and aggregation,
> We don't need many tx buffers. Change the tx number from 10 to 4
> to reduce the usage of the memory. This could save 16K * 6 bytes
> memory.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r8152.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 33dcc97..cc64dc0 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -424,7 +424,7 @@ enum rtl_register_content {
>  	FULL_DUP	= 0x01,
>  };
>  
> -#define RTL8152_MAX_TX		10
> +#define RTL8152_MAX_TX		4
>  #define RTL8152_MAX_RX		10

This driver has a loop that iterates MAX_TX times to initialize both
the RX and TX buffers.

So if they are not equal, it can't possibly work.

Sorry, I'm not applying this.
