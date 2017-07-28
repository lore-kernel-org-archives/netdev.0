From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v11 1/4] net netlink: Add new type
 NLA_BITFIELD_32
Date: Fri, 28 Jul 2017 11:04:24 -0400
Message-ID: <b82ef71c-3231-fa71-44f5-8882750822d9@mojatatu.com>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-2-git-send-email-jhs@emojatatu.com>
 <1a2578ca-35c6-884e-1daf-fcc47e5eb618@gmail.com>
 <7c17a575-53bb-1f25-4a9a-7418f99660f2@mojatatu.com>
 <886e9fe5-d523-4841-1a81-e5671447933a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: David Ahern <dsahern@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36592 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752425AbdG1PE1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 11:04:27 -0400
Received: by mail-io0-f196.google.com with SMTP id j32so9566530iod.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 08:04:27 -0700 (PDT)
In-Reply-To: <886e9fe5-d523-4841-1a81-e5671447933a@gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-28 10:19 AM, David Ahern wrote:
> On 7/28/17 7:51 AM, Jamal Hadi Salim wrote:
>> On 17-07-25 10:41 AM, David Ahern wrote:
>>> On 7/23/17 7:35 PM, Jamal Hadi Salim wrote:
>>>> In the most basic form, the user specifies the attribute policy as:
>>>> [ATTR_GOO] = { .type = NLA_BITFIELD_32, .validation_data =
>>>> &myvalidflags },
>>>>
>>>> where myvalidflags is the bit mask of the flags the kernel understands.
>>>>
>>>> If the user _does not_ provide myvalidflags then the attribute will
>>>> also be rejected.
>>>
>>> No other netlink attribute has this requirement.
>>
>> This is the first one where we have to inspect content. We add things
>> when we need them - as in this case.
> 
> Sure, the validation is required. My argument is that the validation
> should be done where other attributes are validated -- inline with its
> use. Nothing about this new bitfield says it must have a generic
> validation code.
>
Response below.

>>
>>> Users of the attributes
>>> are the only ones that know if a value is valid or not (e.g, attribute
>>> passing a device index) and those are always checked in line.
>>
>> It doesnt make sense that every user of the API has to repeat that
>> validation code. Same principle as someone specifying that a type is
>> u32 and have the nla validation check it. At some point we never had
>> the u32 validation code. Then it was factored out because everyone
>> repeats the same boilerplate code.
> 
> Every user of an attribute that uses a device index must verify the
> device index is valid. The same code is repeated over and over.
> 
> Now you are suggesting to have 1 attribute whose content is validated by
> generic infra and the rest are validated inline by the code using it. I
> believe it is wrong and going to lead to problems.
> 

Kernel side checking for device ifindex must know what a device
ifindex means.
That doesnt disqualify that the generic code checks that it
is of the same size as a signed 32b, etc. That is generic
stuff that can be factored out.

In this case:
Checking for whether bits selected are in the allowed range
that the kernel understands, that the bit value are set in
the right bit position, that the bits set in the correct bit
value position are also selected in the transaction.
That is generic code (which the content validation does).

Checking what bit 5 means - that is specific per kernel user
code. Checking that when bit 5 is selected it is only useful
if bit 3 is unselected - that is specific to the kernel code
consuming those bits.

cheers,
jamal
