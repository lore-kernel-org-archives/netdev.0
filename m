From: Jorge Ramirez <jorge.ramirez-ortiz@linaro.org>
Subject: Re: SIOCSIWFREQ while in NL80211_IFTYPE_STATION
Date: Thu, 5 Jan 2017 14:27:01 +0100
Message-ID: <92e60cb2-8bb4-df03-3434-4a055f575df0@linaro.org>
References: <685811c3-6247-77fd-8c70-617951886451@linaro.org>
 <1483616301.4394.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
        Daniel Lezcano <daniel.lezcano@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f169.google.com ([209.85.210.169]:32949 "EHLO
        mail-wj0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970720AbdAENeH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 08:34:07 -0500
Received: by mail-wj0-f169.google.com with SMTP id tq7so256791962wjb.0
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 05:34:07 -0800 (PST)
In-Reply-To: <1483616301.4394.6.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2017 12:38 PM, Johannes Berg wrote:
> +linux-wireless, where this should've gone

nice. thanks and apologies.

>
>> I am running a single wlan0 interface in managed mode (no aliases,
>> no  other wireless interfaces).
>> The association with the AP still hasn't happened.
>>
>> I noticed that if trying to change the frequency to one of the valid
>> values, the driver returns EBUSY.
>>
>> The call stack is
>> cfg80211_wext_siwfreq
>> -->cfg80211_mgd_wext_siwfreq
>> --->cfg80211_set_monitor_channel (notice call to set 'monitor'
>> channel
>> in managed mode)
>> ----> fails with EBUSY
>>
>> Is therefore the expected behavior to fail under the above
>> circumstances
>> (managed mode && single wlan0 interface && no association)?
>> And if it is, please could you clarify when would it be valid to
>> change the frequency in managed mode?
> Frankly, I don't remember - all of this is plastered all over with
> backward compatibility hooks etc.

yes, that is also what it seems to me: plenty of sedimentation in that 
code path.

>
> How are you running into this? Why are you even trying to do this? You
> really shouldn't use wireless extensions any more.

I am not sure it matters - if I understood your reply, there is no valid 
use case to change the frequency in that mode (and all that code should 
be removed); it seems to me that it is also your view that userspace 
(iwconfig) should be fixed accordingly to not call the extensions?

please let me know if I misunderstood your answer.

I am just trying to understand how the current code is supposed to work 
by exercising widely available user-space tools while debugging the kernel.

I noticed the error (EBUSY) just using the wireless tools package as per 
its man pages.
$ iwconfig wlan0 freq <frequency>

So, what other tool should we use instead of iwconfig (if the use case 
is valid)?

>
> Also, there shouldn't be much reason to be setting the channel anyway,
> unless you want to trigger a connection specifically on that channel,
> but then when you use nl80211 you get that included in the CONNECT
> command there.

> Finally, I suspect that this particular backward compatibility hook
> can't really work anyway and could be removed, but I'm not sure that
> would have the effect you want either.

Actually the frequency gets programmed without errors when reverting 
your commit http://tinyurl.com/ho4urp8 (which comes as a surprise as well).
It seems there is some more users doing the same for research purposes.

https://github.com/seemoo-lab/bcm-rpi3/blob/master/kernel/net/wireless/chan.c#L855



>
> johannes
