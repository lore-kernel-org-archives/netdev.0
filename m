From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: rtl8192se: Fix wrong assignment
Date: Fri, 18 Oct 2013 20:33:42 -0500
Message-ID: <5261E176.1050901@lwfinger.net>
References: <1382143960-4594-1-git-send-email-felipensp@gmail.com> <1382144748.2041.16.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>, Felipe Pena <felipensp@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:60863 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613Ab3JSBdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 21:33:45 -0400
In-Reply-To: <1382144748.2041.16.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2013 08:05 PM, Joe Perches wrote:
> On Fri, 2013-10-18 at 21:52 -0300, Felipe Pena wrote:
>> There is a typo in the struct member name on assignment when checking
>> rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40, the check uses pwrgroup_ht40
>> for bound limit and uses pwrgroup_ht20 when assigning instead.
>>
>> Signed-off-by: Felipe Pena <felipensp@gmail.com>
>> ---
>>   drivers/net/wireless/rtlwifi/rtl8192se/rf.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
>> index 5061f1d..92d38ab 100644
>> --- a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
>> +++ b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
>> @@ -265,7 +265,7 @@ static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
>>   				    rtlefuse->pwrgroup_ht40
>>   				    [RF90_PATH_A][chnl - 1]) {
>>   					pwrdiff_limit[i] =
>> -					  rtlefuse->pwrgroup_ht20
>> +					  rtlefuse->pwrgroup_ht40
>>   					  [RF90_PATH_A][chnl - 1];
>>   				}
>
> Using min could help minimize typos
>
> 					pwrdiff_limit[i] = min(pwrdiff_limit[i],
> 							       rtlefuse->pwrgroup_ht40[RF90_PATH_A][chnl - 1]);

In the initial driver, that would have been true; however, at this point, I 
prefer the patch as submitted. There is less churning of the source.

Larry
