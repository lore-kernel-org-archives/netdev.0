From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RCU PATCH 00/14] Remove qdisc lock around ingress Qdisc
Date: Fri, 14 Mar 2014 00:28:08 -0700
Message-ID: <5322AF88.60702@gmail.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32> <53200588.5060805@mojatatu.com> <53208F11.8010304@gmail.com> <53216FE9.7090604@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:41809 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755133AbaCNH2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 03:28:25 -0400
Received: by mail-ob0-f173.google.com with SMTP id gq1so2168872obb.4
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 00:28:25 -0700 (PDT)
In-Reply-To: <53216FE9.7090604@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2014 01:44 AM, Jamal Hadi Salim wrote:
> On 03/12/14 12:45, John Fastabend wrote:
>> On 03/11/2014 11:58 PM, Jamal Hadi Salim wrote:
>>> On 03/10/14 13:03, John Fastabend wrote:
>>
>> Sure I can provide this data as part of the patch description. My
>> expectation is now that the qdisc lock is not needed there should
>> be less impact to throughput/latency due to filter updates.
>
> Thats what i would think as well (which would be great).
>
>>
>> Yes upto one RCU grace period. Although I don't think this is an
>> issue because we get consistency eventually and even with the qdisc
>> lock there is no way to know if a set of skbs hit the filter list
>> before or after the update.
>>
>
> Probably not a big issue - but needs to be document clearly since the
> expectations have changed.
>
>> I'll get a v2 out tomorrow morning after making Eric's changes and
>> fixing the last compiler warning.
>>
>
> There is one more thing. Actions can be shared. I am wondering how this
> change is going to affect it - can you try this attached script? Sorry,
> I could have sent a much simpler script - but this is one sitting on
> my laptop (i have annotated it - notice the 2 policer instances
> are shared).
> Would be useful to do pings across two devices at the same time while
> concurently doing dumps and see if anything goes crazy (like an oops).

Ran the attached script and modified it to match UDP packets so I could
use it with pktgen to hammer it a bit more. And changed it to add/delete
filters with traffic while doing a watch on the filter and qdisc stats.
No oops, splats or anything else crazy.

I need to get some sleep now though so the performance numbers will have
to wait for tomorrow.

Thanks!
John

-- 
John Fastabend         Intel Corporation
