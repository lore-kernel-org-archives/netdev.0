From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH v2] rtlwifi: Fix logic error in enter/exit power-save mode
Date: Mon, 2 May 2016 12:00:46 -0500
Message-ID: <572787BE.3040101@lwfinger.net>
References: <20160502163835.GA10925@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Wang YanQing <udknight@gmail.com>, kvalo@codeaurora.org,
	chaoming_li@realsil.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33414 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbcEBRAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 13:00:48 -0400
In-Reply-To: <20160502163835.GA10925@udknight>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2016 11:38 AM, Wang YanQing wrote:
> In commit a269913c52ad ("rtlwifi: Rework rtl_lps_leave() and
> rtl_lps_enter() to use work queue"), the tests for enter/exit
> power-save mode were inverted. With this change applied, the
> wifi connection becomes much more stable.
>
> Fixes: a269913c52ad ("rtlwifi: Rework rtl_lps_leave() and rtl_lps_enter() to use work queue")
> Signed-off-by: Wang YanQing <udknight@gmail.com>
> CC: Stable <stable@vger.kernel.org> [3.10+]
> ---
>   Hi, Larry!
>
>   Because commit a269913c52ad is the first commit bring this problem,
>   so maybe use above commit message is ok, right? And stable kernels
>   3.10-3.18 don't have commit fd09ff958777, but have a269913c52ad.
>
>   Thanks for suggestion concerning to good subject and commit message
>   writing, it is harder than coding sometimes:)
>
>   Changes:
>   v1-v2:
>   1: Fix subject and commit message.

Yes, I agree that the commit message is hard.

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks,

Larry

>
>   drivers/net/wireless/realtek/rtlwifi/base.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/base.c b/drivers/net/wireless/realtek/rtlwifi/base.c
> index c74eb13..264466f 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/base.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/base.c
> @@ -1660,9 +1660,9 @@ void rtl_watchdog_wq_callback(void *data)
>   		if (((rtlpriv->link_info.num_rx_inperiod +
>   		      rtlpriv->link_info.num_tx_inperiod) > 8) ||
>   		    (rtlpriv->link_info.num_rx_inperiod > 2))
> -			rtl_lps_enter(hw);
> -		else
>   			rtl_lps_leave(hw);
> +		else
> +			rtl_lps_enter(hw);
>   	}
>
>   	rtlpriv->link_info.num_rx_inperiod = 0;
>
