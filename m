From: Alex Hung <alex.hung@canonical.com>
Subject: Re: [PATCH] rfkill: Add handling when rfkill's type is RFKILL_TYPE_ALL.
Date: Wed, 23 May 2012 14:12:41 +0800
Message-ID: <4FBC7FD9.9080307@canonical.com>
References: <1337589439-14605-1-git-send-email-alex.hung@canonical.com> <1337712399.4470.5.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56923 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183Ab2EWGMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 02:12:49 -0400
In-Reply-To: <1337712399.4470.5.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2012 02:46 AM, Johannes Berg wrote:
> On Mon, 2012-05-21 at 16:37 +0800, Alex Hung wrote:
>> This rfkill type is supposed to be able to toggles the status of all wireless
>> devices; however, no wireless devices will register itself with type
>> RFKILL_TYPE_ALL and thus it was previously ignored in __rfkill_switch_all.
>>
>> Signed-off-by: Alex Hung<alex.hung@canonical.com>
>> ---
>>   net/rfkill/core.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/rfkill/core.c b/net/rfkill/core.c
>> index 5be1957..84dd71a 100644
>> --- a/net/rfkill/core.c
>> +++ b/net/rfkill/core.c
>> @@ -324,7 +324,7 @@ static void __rfkill_switch_all(const enum rfkill_type type, bool blocked)
>>
>>   	rfkill_global_states[type].cur = blocked;
>>   	list_for_each_entry(rfkill,&rfkill_list, node) {
>> -		if (rfkill->type != type)
>> +		if (rfkill->type != type&&  type != RFKILL_TYPE_ALL)
>>   			continue;
>
> Sorry, I accidentally replied to this in private and then Alex replied
> but it all got lost.
>
> He said he was going to change the eeepc use KEY_RFKILL instead of
> KEY_WLAN to switch all types...
>
> So I guess what this change really does is make __rfkill_switch_all() be
> able to not only switch all devices of a given type, but also be able to
> switch all devices of all types.
>
> Alex, can you please rewrite the commit log to make that clearer?
>
> johannes
>

Thanks for your feedback, I re-wrote the comments to clarify the changes 
and re-submitted.

Cheers,
Alex Hung
