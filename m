From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 3/8 V2] rtlwifi: rtl8192cu: Fix smatch warning in rtl8192cu/trx.c
Date: Mon, 16 Sep 2013 23:05:39 +0400
Message-ID: <52375683.8060103@cogentembedded.com>
References: <1379357722-17687-1-git-send-email-Larry.Finger@lwfinger.net> <1379357722-17687-4-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1379357722-17687-4-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/16/2013 10:55 PM, Larry Finger wrote:

> Smatch lists the following:
>    CHECK   drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
> drivers/net/wireless/rtlwifi/rtl8192cu/trx.c:367 _rtl_rx_process() warn: assigning (-98) to unsigned variable 'stats.noise'

> This variable is unused, thus it is removed.

    It's a structure field initializer you're removing, not a variable. And 
also a comment.

> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> ---
>   drivers/net/wireless/rtlwifi/rtl8192cu/trx.c | 2 --
>   1 file changed, 2 deletions(-)

> diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
> index 763cf1d..04c7e57 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
> @@ -349,7 +349,6 @@ bool rtl92cu_rx_query_desc(struct ieee80211_hw *hw,
>   	}
>   	/*rx_status->qual = stats->signal; */
>   	rx_status->signal = stats->rssi + 10;
> -	/*rx_status->noise = -stats->noise; */
>   	return true;
>   }
>
> @@ -364,7 +363,6 @@ static void _rtl_rx_process(struct ieee80211_hw *hw, struct sk_buff *skb)
>   	u8 *rxdesc;
>   	struct rtl_stats stats = {
>   		.signal = 0,
> -		.noise = -98,
>   		.rate = 0,
>   	};

WBR, Sergei


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
