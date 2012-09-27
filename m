From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: use %*ph[C] to dump small buffers
Date: Thu, 27 Sep 2012 10:10:08 -0500
Message-ID: <50646C50.70703@lwfinger.net>
References: <1348667852-5957-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:43309 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480Ab2I0PKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 11:10:12 -0400
In-Reply-To: <1348667852-5957-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2012 08:57 AM, Andy Shevchenko wrote:
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>   drivers/net/wireless/rtlwifi/cam.c          |    7 ++-----
>   drivers/net/wireless/rtlwifi/rtl8192ce/hw.c |    6 ++----
>   drivers/net/wireless/rtlwifi/rtl8192cu/hw.c |    6 ++----
>   3 files changed, 6 insertions(+), 13 deletions(-)

Andy,

Thanks for this. I have only one suggestion. I try to include all the drivers 
affected in the subject line. As this one changes rtl8192ce, and rtl8192cu, I 
would like to see "rtlwifi: rtl8192ce: rtl8192cu: use ..." as the subject. Other 
than that, ACKed-by: Larry Finger <Larry.Finger@lwfinger.net>

Larry

>
> diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
> index 5b4b4d4..6ba9f80 100644
> --- a/drivers/net/wireless/rtlwifi/cam.c
> +++ b/drivers/net/wireless/rtlwifi/cam.c
> @@ -52,11 +52,8 @@ static void rtl_cam_program_entry(struct ieee80211_hw *hw, u32 entry_no,
>   	u32 target_content = 0;
>   	u8 entry_i;
>
> -	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
> -		 "key_cont_128:\n %x:%x:%x:%x:%x:%x\n",
> -		 key_cont_128[0], key_cont_128[1],
> -		 key_cont_128[2], key_cont_128[3],
> -		 key_cont_128[4], key_cont_128[5]);
> +	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "key_cont_128: %*ph\n",
> +			6, key_cont_128);
>
>   	for (entry_i = 0; entry_i < CAM_CONTENT_COUNT; entry_i++) {
>   		target_command = entry_i + CAM_CONTENT_COUNT * entry_no;
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> index 86d73b3..932780d 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> @@ -1918,10 +1918,8 @@ static void rtl92ce_update_hal_rate_mask(struct ieee80211_hw *hw,
>   				     (ratr_index << 28);
>   	rate_mask[4] = macid | (shortgi ? 0x20 : 0x00) | 0x80;
>   	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
> -		 "Rate_index:%x, ratr_val:%x, %x:%x:%x:%x:%x\n",
> -		 ratr_index, ratr_bitmap,
> -		 rate_mask[0], rate_mask[1], rate_mask[2], rate_mask[3],
> -		 rate_mask[4]);
> +		 "Rate_index:%x, ratr_val:%x, %*phC\n",
> +		 ratr_index, ratr_bitmap, 5, rate_mask);
>   	rtl92c_fill_h2c_cmd(hw, H2C_RA_MASK, 5, rate_mask);
>
>   	if (macid != 0)
> diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
> index 4bbb711..7554501 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
> @@ -2169,10 +2169,8 @@ void rtl92cu_update_hal_rate_mask(struct ieee80211_hw *hw, u8 rssi_level)
>   				      ratr_index << 28);
>   	rate_mask[4] = macid | (shortgi ? 0x20 : 0x00) | 0x80;
>   	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
> -		 "Rate_index:%x, ratr_val:%x, %x:%x:%x:%x:%x\n",
> -		 ratr_index, ratr_bitmap,
> -		 rate_mask[0], rate_mask[1], rate_mask[2], rate_mask[3],
> -		 rate_mask[4]);
> +		 "Rate_index:%x, ratr_val:%x, %*phC\n",
> +		 ratr_index, ratr_bitmap, 5, rate_mask);
>   	rtl92c_fill_h2c_cmd(hw, H2C_RA_MASK, 5, rate_mask);
>   }
>
>
