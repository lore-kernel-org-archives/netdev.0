From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v10 1/4] net netlink: Add new type NLA_FLAG_BITS
Date: Mon, 12 Jun 2017 09:51:19 -0400
Message-ID: <22f33fa9-1759-57b7-6aea-898f89c9f61f@mojatatu.com>
References: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
 <1497182026-11594-2-git-send-email-jhs@emojatatu.com>
 <20170611134924.GA1896@nanopsycho.orion>
 <4c536950-2be3-cc9c-1f77-066624800d07@mojatatu.com>
 <4441aa62-d00e-82b6-d337-f86cf97e3c6d@mojatatu.com>
 <20170612103432.GA1993@nanopsycho>
 <8e2f151d-3a02-4b1b-755b-23a0a85556b4@mojatatu.com>
 <20170612114345.GB1993@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34884 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751954AbdFLNwm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 09:52:42 -0400
Received: by mail-it0-f67.google.com with SMTP id f20so921974itb.2
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 06:52:42 -0700 (PDT)
In-Reply-To: <20170612114345.GB1993@nanopsycho>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-06-12 07:43 AM, Jiri Pirko wrote:
> Mon, Jun 12, 2017 at 01:10:56PM CEST, jhs@mojatatu.com wrote:
>> On 17-06-12 06:34 AM, Jiri Pirko wrote:
>>> Sun, Jun 11, 2017 at 08:37:25PM CEST, jhs@mojatatu.com wrote:
>>>> On 17-06-11 01:38 PM, Jamal Hadi Salim wrote:
>>>>> On 17-06-11 09:49 AM, Jiri Pirko wrote:
>>>>>> Sun, Jun 11, 2017 at 01:53:43PM CEST, jhs@mojatatu.com wrote:
>>>>>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>>>>
>>>>>
>>>>>>> This patch also provides an extra feature: a validation callback
>>>>>>> that could be speaciliazed for other types.
>>>>>>
>>>>>> s/speaciliazed/speciliazed/
>>>>>>
>>>>>
>>>>> Will fix.
>>>>>
>>>>>
>>>>>>>
>>>>>>> [ATTR_GOO] = { .type = MYTYPE,
>>>>>>>              .validation_data = &myvalidation_data,
>>>>>>>                  .validate_content = mycontent_validator },
>>>>>>
>>>>>> Indent is wrong. (Does not matter really in desc, but anyway)
>>>>>>
>>>>>
>>>>> I cant find out how it got indented that way; my source
>>>>> or email dont show it as such (but really doesnt matter).
>>>>>
>>>>>
>>>>>> Suggested-by: Jiri Pirko <jiri@mellanox.com>
>>>>>>
>>>>>
>>>>> Will add.
>>>>>
>>>>>>

>>> I believe that this struct should go into:
>>> include/uapi/linux/netlink.h
>>>
>>> struct nla_flag_bits {
>>> 	__u32 nla_flag_bits_values;
>>> 	__u32 nla_flag_bits_selector;
>>> };
>>>
>>> Then you can use it from userspace and everywhere in kernel.
>>>
>> That file seems to be very out of place for this stuff.
> 
> Howcome? It is a common netlink api.
> 

Take a look at that file's content. It talks about what goes in
the netlink header. Adding types in it seems out of place.


>> NLA_XXX are kernel side types.  They are part of net/netlink.h which is
>> not uapi accessible.
>> David Ahern has submitted a patch to move all those defines to iproute2.
>> Will make sense to move these to a uapi/linux/netlink-types.h but that
>> is waay beyond the scope of this patch set.
> 
> Well, I don't think so :)
> 
> The thing is, struct nla_flag_bits is tightly coupled with NLA_FLAG_BITS
> enum value. They should be in the same uapi file. That makes sense to me.
> 

Sure - they should be in the same file. But is it uapi/linux/netlink.h?

cheers,
jamal
