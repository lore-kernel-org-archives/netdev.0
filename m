From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2 V2 3.18] rtlwifi: rtl8821ae: Fix 5G detection problem
Date: Tue, 25 Nov 2014 23:10:36 +0300
Message-ID: <5474E23C.8090208@cogentembedded.com>
References: <1416945727-10743-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Valerio Passini <valerio.passini@unicam.it>
To: Larry Finger <Larry.Finger@lwfinger.net>, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:61475 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbaKYUKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 15:10:40 -0500
Received: by mail-la0-f44.google.com with SMTP id ge10so1243564lab.31
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 12:10:39 -0800 (PST)
In-Reply-To: <1416945727-10743-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/25/2014 11:02 PM, Larry Finger wrote:

> The changes associated with moving this driver from staging to the regular
> tree missed one section setting the allowable rates for the 5GHz band.

> This patch is needed to fix the regression reported in Bug #88811
> (https://bugzilla.kernel.org/show_bug.cgi?id=88811).

> Reported-by: Valerio Passini <valerio.passini@unicam.it>
> Tested-by: Valerio Passini <valerio.passini@unicam.it>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Valerio Passini <valerio.passini@unicam.it>
> ---

> V2 - removed extra parentheses as suggested by John Linville.

    He's also suggested spaces around << in his example

> ---
>   drivers/net/wireless/rtlwifi/rtl8821ae/hw.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
> index 310d316..18f34f7 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
> @@ -3672,8 +3672,9 @@ static void rtl8821ae_update_hal_rate_mask(struct ieee80211_hw *hw,
>   		mac->opmode == NL80211_IFTYPE_ADHOC)
>   		macid = sta->aid + 1;
>   	if (wirelessmode == WIRELESS_MODE_N_5G ||
> -	    wirelessmode == WIRELESS_MODE_AC_5G)
> -		ratr_bitmap = sta->supp_rates[NL80211_BAND_5GHZ];
> +	    wirelessmode == WIRELESS_MODE_AC_5G ||
> +	    wirelessmode == WIRELESS_MODE_A)
> +		ratr_bitmap = sta->supp_rates[NL80211_BAND_5GHZ]<<4;

    The kernel style generally assumes spaces around operators, and it would 
only be consistent with the other code in the vicinity if you added them...

WBR, Sergei
