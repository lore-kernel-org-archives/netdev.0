From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v5 1/2] sctp: check the rto_min and rto_max
Date: Sun, 08 Dec 2013 21:31:08 -0500
Message-ID: <52A52B6C.7030305@gmail.com>
References: <1386400651-21744-1-git-send-email-wangweidong1@huawei.com> <1386400651-21744-2-git-send-email-wangweidong1@huawei.com> <52A31805.8020305@redhat.com> <52A37080.2010703@gmail.com> <52A38F36.8080609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wang Weidong <wangweidong1@huawei.com>, nhorman@tuxdriver.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:65017 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755566Ab3LICbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 21:31:12 -0500
In-Reply-To: <52A38F36.8080609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2013 04:12 PM, Daniel Borkmann wrote:
> On 12/07/2013 08:01 PM, Vlad Yasevich wrote:
>> On 12/07/2013 07:43 AM, Daniel Borkmann wrote:
>>> On 12/07/2013 08:17 AM, Wang Weidong wrote:
>>>> rto_min should be smaller than rto_max while rto_max should be larger
>>>> than rto_min. Add two proc_handler for the checking. Add the check in
>>>> sctp_setsockopt_rtoinfo.
>>>>
>>>> Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
>>>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>>>> ---
>>>
>>> Thanks Wang, also for your second patch.
>>>
>>> Second one looks good to me, thanks for the cleanup!
>>>
>>> I was wondering where 86400000 comes from? Looking through the git
>>> history didn't give much clues and the RFC4960 neither. Clearly,
>>> section 15 of RFC4960 *recommends* as initial values ...
>>>
>>>    RTO.Initial - 3 seconds
>>>    RTO.Min - 1 second
>>>    RTO.Max - 60 seconds
>>>
>>> ... which we have as constants in [1] and are assigned to globals
>>> initially in [2,3] with those recommended values. That's all good.
>>>
>>> But still [not *directly* related to your patch though], where does
>>> 86400000 come from? I expect that's for the max SCTP heartbeat
>>> interval or max cookie lifetime?
>>
>> No, initially it was defined as rto_timer_max and was the upper bound
>> for the rto timer.   When you think about it, it's a bit ridiculous
>> really.  What you are saying is that your rto timer is allowed to
>> grow as long as 1 day, so you would at an absolute maximum retransmit
>> one packet per day :)
> 
> Exactly, maybe initial SCTP implementors already took into account
> we could have SCTP connections to other galaxies, but clearly untested
> so far? :)
> 
> I think we should be absolutely fine with a max configurable upper
> limit of twice the recommended RTO.Max value from the RFC.

That would only put at at 2 min...  That may not be enough in certain
deployments.  Yes, they always have the option to set it per socket,
but that becomes a pain and harder to tune the same app to different
links.  I think 2 hours might be a safer maximum RTO.Max, but I find
it hard to justify shrinking this value.  It isn't really broken
and if someone does set it to 6 hours, they really are shooting
themselves in the foot :)

-vlad

> 
>> I don't think this limit is specified anywhere as is though.  It
>> was something that's been there since the 2.5 days.
>>
>> -vlad
