From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 0/5] net_sched: Add support for IFE action
Date: Tue, 23 Feb 2016 07:09:14 -0500
Message-ID: <56CC4BEA.70108@mojatatu.com>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
 <56CB3B90.8030206@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38702 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbcBWMJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 07:09:23 -0500
Received: by mail-ig0-f169.google.com with SMTP id y8so101920191igp.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 04:09:23 -0800 (PST)
In-Reply-To: <56CB3B90.8030206@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On 16-02-22 11:47 AM, Daniel Borkmann wrote:
> Hi Jamal,
>
> On 02/22/2016 02:21 PM, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>>
>> As agreed at netconf in Seville, here's the patch finally (1 year
>> was just too long to wait).
>> Described in netdev01 paper:
>>              "Distributing Linux Traffic Control Classifier-Action
>> Subsystem"
>>               Authors: Jamal Hadi Salim and Damascene M. Joachimpillai
>>
>> Allows for incremental updates for new metadatum support.
>> This patch set includes support for basic skb metadatum
>> Followup patches will have more examples of metadata
>
> So, basically this is a L2 encap with TLVs, right?
>
> And as TLVs you have skb->mark, skb->priority, skb->hash,
> skb->queue_mapping
> that you transfer from one machine to another, where on the destination,
> you
> are applying the above meta data to the skb itself. And, configuration
> is via
> tc.
>
> I couldn't parse from the commit log what the real world use case is, resp.
> who is going to use this infrastructure?
>
> Do you have some typical setup, where the above needs to be transferred
> in the
> encap and restored?
>

I am assuming you are asking this for the sake of people who dont
have context (and not for yourself)?
I added a pointer to the paper. It is 6 pages and simple to read.
Isnt that sufficient? I dont want to write a novel here. Some could
argue that in fact i am already writing a novel in commit 1/5.

>> Jamal Hadi Salim (5):
>>    introduce IFE action
>>    Support to encoding decoding skb mark on IFE action
>>    Support to encoding decoding skb prio on IFE action
>>    Support to encoding decoding skb hashid on IFE action
>>    Support to encoding decoding skb queue map on IFE action
>>
>>   include/net/tc_act/tc_ife.h        |  60 +++
>>   include/uapi/linux/tc_act/tc_ife.h |  38 ++
>>   net/sched/Kconfig                  |  32 ++
>>   net/sched/Makefile                 |   5 +
>>   net/sched/act_ife.c                | 865
>> +++++++++++++++++++++++++++++++++++++
>>   net/sched/act_meta_mark.c          |  81 ++++
>>   net/sched/act_meta_qmap.c          | 100 +++++
>>   net/sched/act_meta_skbhash.c       |  87 ++++
>>   net/sched/act_meta_skbprio.c       |  80 ++++
>
> Splitting these set/get functions into individual modules where you only
> set/get a single skb member seems overkill to me. Could be done with a
> simple switch statement inside ife?
>

They need to be separated to make them unique. These are basic
metadatum; I have a few others lined up - but i just wanted to start
with these because they are obvious to see. What i mulled over is
to send one big patch or several. In the end it seemed cleaner to
send separate patches.

Thanks for your other input - I will redo, test and submit v2.

cheers,
jamal
