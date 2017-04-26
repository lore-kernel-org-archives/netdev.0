From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 09:00:04 -0400
Message-ID: <ac6da456-04b4-ba0c-683a-3beef49c9949@mojatatu.com>
References: <1493121247-11863-1-git-send-email-jhs@emojatatu.com>
 <1493121247-11863-3-git-send-email-jhs@emojatatu.com>
 <20170425121338.GC1867@nanopsycho.orion>
 <5e54edd8-3943-6f09-490f-ff04b83077f6@mojatatu.com>
 <20170425160445.GD1867@nanopsycho.orion>
 <4b7789f7-69e0-4764-7029-f6e15d6e7d69@mojatatu.com>
 <20170426061904.GB1867@nanopsycho.orion>
 <20170426110750.GB28251@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34171 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757946AbdDZNAH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:00:07 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so352995ioi.1
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 06:00:06 -0700 (PDT)
In-Reply-To: <20170426110750.GB28251@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-26 07:07 AM, Simon Horman wrote:
> On Wed, Apr 26, 2017 at 08:19:04AM +0200, Jiri Pirko wrote:
>> Tue, Apr 25, 2017 at 10:29:40PM CEST, jhs@mojatatu.com wrote:
>
> ...
>
>>> So lets in first kernel I have support for bit 0.
>>> My validation check is to make sure only bit 0 is set.
>>> The valid_flags currently then only constitutes bit 0.
>>> i.e
>>> If you set bit 2 or 3, the function above will reject and i return
>>> the error to the user.
>>>
>>> That is expected behavior correct?
>>>
>>> 3 months down the road:
>>> I add two flags - bit 1 and 2.
>>> So now my valid_flags changes to bits 1, 2 and 0.
>>>
>>> The function above will now return true for bits 0-2 but
>>> will reject if you set bit 3.
>>>
>>> That is expected behavior, correct?
>>
>> The same app compiled against new kernel with bits (0, 1, 2) will run with
>> this kernel good. But if you run it with older kernel, the kernel (0)
>> would refuse. Is that ok?
>
> Conversely, if an app is compiled against a new kernel and uses ATTR0, ATTR1
> and ATTR2 all will be well. But if you run it against the older kernel
> ATTR1 and ATTR2 will be silently ignored. I believe that is how its always
> been but is that ok?
>

I think the answer is much complex than ok/notok.

If i have bits that when not supported by the kernel would result in
bad operations then of course kernel ignoring their presence is a very
bad thing (Dave's example is "I want you to encrypt" which an old
kernel wont understand).
There's also a security concern where flags are being set and are being
randomly accepted by old kernels resulting in root access etc.

The other side of the coin, if I really dont care if you dont understand
the extra bits I have set i would like you to do what you can.
Thats status quo upto now.

So my overall view:
Ignoring how it used to work is a revolution not an evolution.
There will be a blood bath with existing apps before the new norm comes
into proper effect.

cheers,
jamal
