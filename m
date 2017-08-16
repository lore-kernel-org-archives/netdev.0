From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Subject: Re: [patch net-next 0/3] net/sched: Improve getting objects by
 indexes
Date: Wed, 16 Aug 2017 11:41:11 +0200
Message-ID: <e13dd37c-f323-ba92-a7a6-cd3515c20ccc@amd.com>
References: <1502849538-14284-1-git-send-email-chrism@mellanox.com>
 <144b87a3-bbe4-a194-ed83-e54840d7c7c2@amd.com>
 <20170816081631.GC1868@nanopsycho>
 <e3cb8f8e-7808-48b4-d90d-67f30ab39687@amd.com>
 <20170816083939.GD1868@nanopsycho>
 <5867bd36-b758-f364-062a-2b612e8c7318@amd.com>
 <20170816093144.GE1868@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0044.outbound.protection.outlook.com ([104.47.42.44]:61515
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751654AbdHPJlX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 05:41:23 -0400
In-Reply-To: <20170816093144.GE1868@nanopsycho>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 16.08.2017 um 11:31 schrieb Jiri Pirko:
> [SNIP]
> I don't. It is an API change, maintainers of the individual drivers are
> not expected to review the patches like this.

Yeah, completely agree.

>> If yes then it somehow makes sense to send the patch bit by bit, if no then
>> it doesn't seem to make to much sense to CC them all individually.
>>
>>>>>> I've never read the bsg code before, but that's certainly not correct. And
>>>>>> that incorrect pattern repeats over and over again in this code.
>>>>>>
>>>>>> Apart from that why the heck do you want to allocate more than 1<<31 handles?
>>>>> tc action indexes for example. That is part of this patchset.
>>>> Well, let me refine the question: Why does tc action indexes need more than
>>>> 31 bits? From an outside view that looks like pure overkill.
>>> That is current state, uapi. We have to live with it.
>> Is the range to allocate from part of the uapi or what is the issue here?
> Yes.

A bit strange uapi design, but ok in this case that change actually 
makes sense.

>> If the issue is that userspace can specify the handle then I suggest that you
>> use the radix tree directly instead of the idr wrapper around it.
> But why? idr is exactly the tool we need. Only signed int does not suit
> us. In fact, it does not make sense idr is using signed int when it
> uses radix tree with unsigned long under the hood.

Well it always depends on what you do and how to use it.

In amdgpu for example for have very very short lived objects and only 
few of them are active at the same time.

The solution was not to use and idr, but rather 64bit identifiers and a 
ring buffer with the last 128 entries.

But in your case changing the idr calling convention actually makes 
sense (at least from the tn mile high view), feel free to add an 
Acked-by: Christian König <christian.koenig@amd.com> on it.

Regards,
Christian.
