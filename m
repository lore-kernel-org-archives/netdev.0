From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH] mwifiex: fix memory leak on regd when chan is zero
Date: Thu, 15 Sep 2016 18:26:26 +0100
Message-ID: <6afd51c2-c603-c887-3d75-3a1775bfe11c@canonical.com>
References: <20160915162117.1209-1-colin.king@canonical.com>
 <87vaxx9jhk.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:48168 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbcIOR2H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 13:28:07 -0400
In-Reply-To: <87vaxx9jhk.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/09/16 18:10, Kalle Valo wrote:
> Colin King <colin.king@canonical.com> writes:
> 
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> When chan is zero mwifiex_create_custom_regdomain does not kfree
>> regd and we have a memory leak. Fix this by freeing regd before
>> the return.
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>> ---
>>  drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c b/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
>> index 3344a26..15a91f3 100644
>> --- a/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
>> +++ b/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
>> @@ -1049,8 +1049,10 @@ mwifiex_create_custom_regdomain(struct mwifiex_private *priv,
>>  		enum nl80211_band band;
>>  
>>  		chan = *buf++;
>> -		if (!chan)
>> +		if (!chan) {
>> +			kfree(regd);
>>  			return NULL;
>> +		}
> 
> Bob sent a similar fix and he also did more:
> 
> mwifiex: fix error handling in mwifiex_create_custom_regdomain
> 
> https://patchwork.kernel.org/patch/9331337/
> 
Ah, sorry for the duplication noise.

Colin
