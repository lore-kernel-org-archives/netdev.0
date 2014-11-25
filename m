From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/2 3.18] rtlwifi: rtl8821ae: Fix 5G detection problem
Date: Tue, 25 Nov 2014 13:50:32 -0600
Message-ID: <5474DD88.7060002@lwfinger.net>
References: <1416933127-25912-1-git-send-email-Larry.Finger@lwfinger.net> <1416933127-25912-2-git-send-email-Larry.Finger@lwfinger.net> <20141125184625.GC15476@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Valerio Passini <valerio.passini@unicam.it>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:59779 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbaKYTvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:51:03 -0500
In-Reply-To: <20141125184625.GC15476@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/2014 12:46 PM, John W. Linville wrote:
> On Tue, Nov 25, 2014 at 10:32:06AM -0600, Larry Finger wrote:
>> The changes associated with moving this driver from staging to the regular
>> tree missed one section setting the allowable rates for the 5GHz band.
>>
>> This patch is needed to fix the regression reported in Bug #88811
>> (https://bugzilla.kernel.org/show_bug.cgi?id=88811).
>>
>> Reported-by: Valerio Passini <valerio.passini@unicam.it>
>> Tested-by: Valerio Passini <valerio.passini@unicam.it>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> Cc: Valerio Passini <valerio.passini@unicam.it>
>> ---
>>   drivers/net/wireless/rtlwifi/rtl8821ae/hw.c | 5 +++--
>>   1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
>> index 310d316..18f34f7 100644
>> --- a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
>> +++ b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
>> @@ -3672,8 +3672,9 @@ static void rtl8821ae_update_hal_rate_mask(struct ieee80211_hw *hw,
>>   		mac->opmode == NL80211_IFTYPE_ADHOC)
>>   		macid = sta->aid + 1;
>>   	if (wirelessmode == WIRELESS_MODE_N_5G ||
>> -	    wirelessmode == WIRELESS_MODE_AC_5G)
>> -		ratr_bitmap = sta->supp_rates[NL80211_BAND_5GHZ];
>> +	    wirelessmode == WIRELESS_MODE_AC_5G ||
>> +	    wirelessmode == WIRELESS_MODE_A)
>> +		ratr_bitmap = (sta->supp_rates[NL80211_BAND_5GHZ])<<4;
>
> The parenthesis seem superfluous.  How about this line instead?
>
> +		ratr_bitmap = sta->supp_rates[NL80211_BAND_5GHZ] << 4;
>
>>   	else
>>   		ratr_bitmap = sta->supp_rates[NL80211_BAND_2GHZ];

Good idea. V2 is on its way.

Larry
