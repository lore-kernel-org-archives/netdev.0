From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 06/10] mac80211: Add sta_state to ethtool stats.
Date: Thu, 12 Apr 2012 07:48:36 -0700
Message-ID: <4F86EB44.3080703@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>  <1334166738-28243-7-git-send-email-greearb@candelatech.com>  (sfid-20120411_195329_226978_FB464821) <1334202554.3788.9.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60948 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964991Ab2DLOsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 10:48:42 -0400
In-Reply-To: <1334202554.3788.9.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2012 08:49 PM, Johannes Berg wrote:
> On Wed, 2012-04-11 at 10:52 -0700, greearb@candelatech.com wrote:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> Helps to know how the station is doing in it's association
>> attempt.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>> ---
>> :100644 100644 bbaf564... a63834d... M	net/mac80211/cfg.c
>>   net/mac80211/cfg.c |    6 ++++--
>>   1 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
>> index bbaf564..a63834d 100644
>> --- a/net/mac80211/cfg.c
>> +++ b/net/mac80211/cfg.c
>> @@ -118,7 +118,7 @@ static const char ieee80211_gstrings_sta_stats[][ETH_GSTRING_LEN] = {
>>   	"rx_duplicates", "rx_fragments", "rx_dropped",
>>   	"tx_packets", "tx_bytes", "tx_fragments",
>>   	"tx_filtered", "tx_retry_failed", "tx_retries",
>> -	"beacon_loss", "txrate", "rxrate", "signal",
>> +	"beacon_loss", "sta_state", "txrate", "rxrate", "signal",
>>   	"channel", "noise", "ch_time", "ch_time_busy",
>>   	"ch_time_ext_busy", "ch_time_rx", "ch_time_tx"
>>   };
>> @@ -534,10 +534,12 @@ static void ieee80211_get_et_stats(struct wiphy *wiphy,
>>   		data[i++] += sta->beacon_loss_count;
>>
>>   		if (!do_once) {
>> -			i += 3;
>> +			i += 4;
>>   			goto after_once;
>>   		}
>>
>> +		data[i++] = sta->sta_state;
>> +
>
> Gee, I wish it was easier to tell if you were adding it to the right
> spot in the list ... any way that could be made easier?

It would be nice, but I haven't thought of an easy way to do this,
and I haven't noticed any other drivers
that found a way.

I *could* add a lot of #defines and do something like: data[STA_STATE_IDX] = sta->state,
and maybe create the strings array at run-time using macros to map string to
an idx define instead of have a static array of char*.  But, I'm not sure if
it's worth the effort.

Thanks,
Ben

>
> johannes


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
