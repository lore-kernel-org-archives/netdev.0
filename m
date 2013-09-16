From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 5/7: rtlwifi: Fix smatch warning in pci.c
Date: Mon, 16 Sep 2013 12:39:51 -0500
Message-ID: <52374267.9040200@lwfinger.net>
References: <1379094304-22041-1-git-send-email-Larry.Finger@lwfinger.net> <1379094304-22041-6-git-send-email-Larry.Finger@lwfinger.net> <AE90C24D6B3A694183C094C60CF0A2F6026B733B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:49405 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149Ab3IPRjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 13:39:54 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B733B@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2013 04:26 AM, David Laight wrote:
>> Smatch reports the following:
>>    CHECK   drivers/net/wireless/rtlwifi/pci.c
>> drivers/net/wireless/rtlwifi/pci.c:739 _rtl_pci_rx_interrupt() warn: assigning (-98) to unsigned
>> variable 'stats.noise'
>>
>> This problem is fixed by changing the value to 256 - 98.
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> ---
>>   drivers/net/wireless/rtlwifi/pci.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
>> index 703f839..bf498f5 100644
>> --- a/drivers/net/wireless/rtlwifi/pci.c
>> +++ b/drivers/net/wireless/rtlwifi/pci.c
>> @@ -736,7 +736,7 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
>>
>>   	struct rtl_stats stats = {
>>   		.signal = 0,
>> -		.noise = -98,
>> +		.noise = 158,	/* -98 dBm */
>>   		.rate = 0,
>>   	};
>>   	int index = rtlpci->rx_ring[rx_queue_idx].idx;
>
> That doesn't look nice at all.
> Something like (unsigned int)-98 would be slightly better,
> but it looks as though something is actually wrong with
> the type of 'noise' itself.

The type of 'noise' is probably a legacy of wireless extensions. In fact, that 
variable is not used and will be deleted in V2 of the patches.

Thanks,

Larry
