From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] rtlwifi: Fix improve function 'rtl_addr_delay()' in
 core.c
Date: Wed, 3 Feb 2016 14:41:26 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCD5486@AcuExch.aculab.com>
References: <20160203015953.GA13562@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"chaoming_li@realsil.com.cn" <chaoming_li@realsil.com.cn>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Byeoungwook Kim' <quddnr145@gmail.com>,
	"Larry.Finger@lwfinger.net" <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160203015953.GA13562@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Byeoungwook Kim
> Sent: 03 February 2016 02:00
> Conditional codes in rtl_addr_delay() were improved in readability and
> performance by using switch codes.

I'd like to see the performance data :-)

> diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
> index 4ae421e..05f432c 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/core.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/core.c
> @@ -37,18 +37,26 @@
> 
>  void rtl_addr_delay(u32 addr)
>  {
> -	if (addr == 0xfe)
> +	switch (addr) {
> +	case 0xfe:
>  		mdelay(50);
> -	else if (addr == 0xfd)
> +		break;
> +	case 0xfd:
>  		mdelay(5);
> -	else if (addr == 0xfc)
> +		break;
> +	case 0xfc:
>  		mdelay(1);
> -	else if (addr == 0xfb)
> +		break;
> +	case 0xfb:
>  		udelay(50);
> -	else if (addr == 0xfa)
> +		break;
> +	case 0xfa:
>  		udelay(5);
> -	else if (addr == 0xf9)
> +		break;
> +	case 0xf9:
>  		udelay(1);
> +		break;
> +	};

Straight 'performance' can't matter here, not with mdelay(50)!
The most likely effect is from speeding up the 'don't delay' path
and reducing the number of conditionals (and hence accuracy of) udelay(1).
Reversing the if-chain might be better still.

	David
