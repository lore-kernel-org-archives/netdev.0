From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi:rtl_watchdog_wq_callback: fix calling
 rtl_lps_enter|rtl_lps_leave in opposite condition
Date: Mon, 2 May 2016 10:40:34 -0500
Message-ID: <572774F2.2050304@lwfinger.net>
References: <20160502053754.GA30313@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Wang YanQing <udknight@gmail.com>, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35088 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbcEBPkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 11:40:37 -0400
In-Reply-To: <20160502053754.GA30313@udknight>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2016 12:37 AM, Wang YanQing wrote:
> Commit a269913c52ad37952a4d9953bb6d748f7299c304
> ("rtlwifi: Rework rtl_lps_leave() and rtl_lps_enter() to use work queue")
> make a mistake, change the meaning of num_tx|rx_inperiod comparison test.
>
> Commit fd09ff958777cf583d7541f180991c0fc50bd2f7
> ("rtlwifi: Remove extra workqueue for enter/leave power state")
> follow previous mistake, bring us to current code.
>
> This patch fix it.
>
> Signed-off-by: Wang YanQing <udknight@gmail.com>
> ---
>   I think this patch should be ported back to stable kernels, 3.10+.
>   In my machine, I will lost wifi connection after minutes if I enable
>   fwlps.
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

NACK

This patch is correct. There is a logic error in entering/exiting power-save 
mode. Thus the code part is OK; however, the subject and commit message need to 
be improved. If I had prepared this patch, my subject would have been "rtlwifi: 
Fix logic error in enter/exit power-save mode". For the commit message, I would 
have used the following:

In commit fd09ff958777 ("rtlwifi: Remove extra workqueue for enter/leave power 
state"), the tests for enter/exit power-save mode were inverted. With this 
change applied, the wifi connection becomes much more stable.

Fixes: fd09ff958777 ("rtlwifi: Remove extra workqueue for enter/leave power state")
Signed-off-by: Wang YanQing <udknight@gmail.com>
CC: Stable <stable@vger.kernel.org> [3.10+]
---

Thanks for finding this problem.

Larry
