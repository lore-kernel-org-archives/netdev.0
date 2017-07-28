From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v11 1/4] net netlink: Add new type
 NLA_BITFIELD_32
Date: Fri, 28 Jul 2017 16:55:36 +0200
Message-ID: <20170728145536.GE1857@nanopsycho>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-2-git-send-email-jhs@emojatatu.com>
 <1a2578ca-35c6-884e-1daf-fcc47e5eb618@gmail.com>
 <7c17a575-53bb-1f25-4a9a-7418f99660f2@mojatatu.com>
 <886e9fe5-d523-4841-1a81-e5671447933a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34786 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751737AbdG1Ozj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:55:39 -0400
Received: by mail-wm0-f67.google.com with SMTP id x64so3413187wmg.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:55:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <886e9fe5-d523-4841-1a81-e5671447933a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 28, 2017 at 04:19:06PM CEST, dsahern@gmail.com wrote:
>On 7/28/17 7:51 AM, Jamal Hadi Salim wrote:
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
>Sure, the validation is required. My argument is that the validation
>should be done where other attributes are validated -- inline with its
>use. Nothing about this new bitfield says it must have a generic
>validation code.
>
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
>Every user of an attribute that uses a device index must verify the
>device index is valid. The same code is repeated over and over.

This is something different. You don't have NLA_IFINDEX. If you'd have it,
might make sense to do validation on Netlink level. Ofc this is highly
hypothetical. But in Jamal's case, there is indeed NLA_BITFIELD32 and
this attribute type itself assumes some format. Therefore the validation
on Netlink level makes sense here. At least that is how I feel it.


>
>Now you are suggesting to have 1 attribute whose content is validated by
>generic infra and the rest are validated inline by the code using it. I
>believe it is wrong and going to lead to problems.
