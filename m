From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv2] rtlwifi: rtl8192ce: rtl8192cu: use %*ph[C] to dump
 small buffers
Date: Mon, 01 Oct 2012 04:14:55 -0700
Message-ID: <1349090095.7740.9.camel@joe-AO722>
References: <1349088899-15863-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"David S . Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:50737 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751947Ab2JALO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 07:14:56 -0400
In-Reply-To: <1349088899-15863-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-01 at 13:54 +0300, Andy Shevchenko wrote:
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ACKed-by: Larry Finger <Larry.Finger@lwfinger.net>

Hey Andy.

The conversions are not all the same.
One uses "%*ph", the others use "%*phC"
even though all origin hex formats are "%x:%x:..."
Ideally all the conversions would use the same format style.

> diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c

> @@ -52,11 +52,8 @@ static void rtl_cam_program_entry(struct ieee80211_hw *hw, u32 entry_no,
[]
> -	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
> -		 "key_cont_128:\n %x:%x:%x:%x:%x:%x\n",
> -		 key_cont_128[0], key_cont_128[1],
> -		 key_cont_128[2], key_cont_128[3],
> -		 key_cont_128[4], key_cont_128[5]);
> +	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "key_cont_128: %*ph\n",
> +			6, key_cont_128);

Uses "%*ph"
You removed a newline.
That should probably be mentioned in the changelog.

It would be a bit nicer as well to align the arguments
after the open paren like:

	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "key_cont_128: %*ph\n",
		 6, key_cont_128);

> diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
[]
> @@ -1918,10 +1918,8 @@ static void rtl92ce_update_hal_rate_mask(struct ieee80211_hw *hw,
[]
> -		 "Rate_index:%x, ratr_val:%x, %x:%x:%x:%x:%x\n",
> -		 ratr_index, ratr_bitmap,
> -		 rate_mask[0], rate_mask[1], rate_mask[2], rate_mask[3],
> -		 rate_mask[4]);
> +		 "Rate_index:%x, ratr_val:%x, %*phC\n",
> +		 ratr_index, ratr_bitmap, 5, rate_mask);

Uaes "%*phC", etc...

> diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
[]
> @@ -2169,10 +2169,8 @@ void rtl92cu_update_hal_rate_mask(struct ieee80211_hw *hw, u8 rssi_level)
[]
> -		 "Rate_index:%x, ratr_val:%x, %x:%x:%x:%x:%x\n",
> -		 ratr_index, ratr_bitmap,
> -		 rate_mask[0], rate_mask[1], rate_mask[2], rate_mask[3],
> -		 rate_mask[4]);
> +		 "Rate_index:%x, ratr_val:%x, %*phC\n",
> +		 ratr_index, ratr_bitmap, 5, rate_mask);

here too
