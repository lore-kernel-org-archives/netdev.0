From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 0/5] net_sched: Add support for IFE action
Date: Tue, 23 Feb 2016 14:20:54 +0100
Message-ID: <56CC5CB6.1030807@iogearbox.net>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com> <56CB3B90.8030206@iogearbox.net> <56CC4BEA.70108@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45320 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbcBWNU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 08:20:58 -0500
In-Reply-To: <56CC4BEA.70108@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2016 01:09 PM, Jamal Hadi Salim wrote:
> On 16-02-22 11:47 AM, Daniel Borkmann wrote:
[...]
>> So, basically this is a L2 encap with TLVs, right?
>>
>> And as TLVs you have skb->mark, skb->priority, skb->hash,
>> skb->queue_mapping
>> that you transfer from one machine to another, where on the destination,
>> you
>> are applying the above meta data to the skb itself. And, configuration
>> is via
>> tc.
>>
>> I couldn't parse from the commit log what the real world use case is, resp.
>> who is going to use this infrastructure?
>>
>> Do you have some typical setup, where the above needs to be transferred
>> in the
>> encap and restored?
>
> I am assuming you are asking this for the sake of people who dont
> have context (and not for yourself)?
> I added a pointer to the paper. It is 6 pages and simple to read.
> Isnt that sufficient? I dont want to write a novel here. Some could
> argue that in fact i am already writing a novel in commit 1/5.

Ok, the paper talks about, quote:

  - Pipeline-stage Indexing.
  - OAM information - example turn on some packet debug information on a need basis.
  - Exception handling information - example VXLAN service handling.
  - Authentication and authorization information.
  - Versioning information.
  - Compliance information.
  - Service Identifiers.

As your primary examples, you provide skb->mark, skb->priority, skb->hash,
skb->queue_mapping for encapsulating, f.e. how do you use skb>hash in this
scenario? What's the use-case?

>>> Jamal Hadi Salim (5):
>>>    introduce IFE action
>>>    Support to encoding decoding skb mark on IFE action
>>>    Support to encoding decoding skb prio on IFE action
>>>    Support to encoding decoding skb hashid on IFE action
>>>    Support to encoding decoding skb queue map on IFE action
>>>
>>>   include/net/tc_act/tc_ife.h        |  60 +++
>>>   include/uapi/linux/tc_act/tc_ife.h |  38 ++
>>>   net/sched/Kconfig                  |  32 ++
>>>   net/sched/Makefile                 |   5 +
>>>   net/sched/act_ife.c                | 865
>>> +++++++++++++++++++++++++++++++++++++
>>>   net/sched/act_meta_mark.c          |  81 ++++
>>>   net/sched/act_meta_qmap.c          | 100 +++++
>>>   net/sched/act_meta_skbhash.c       |  87 ++++
>>>   net/sched/act_meta_skbprio.c       |  80 ++++
>>
>> Splitting these set/get functions into individual modules where you only
>> set/get a single skb member seems overkill to me. Could be done with a
>> simple switch statement inside ife?
>
> They need to be separated to make them unique. These are basic
> metadatum; I have a few others lined up - but i just wanted to start
> with these because they are obvious to see. What i mulled over is
> to send one big patch or several. In the end it seemed cleaner to
> send separate patches.

But just to make them unique, you don't need to add extra modules for
this ... just having a module for encoding one skb member seems like
total overdesign to me. If you really want them to be separate ops,
you can still include them into act_ife.c itself.

Thanks,
Daniel
