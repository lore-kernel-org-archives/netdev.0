From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v11 1/4] net netlink: Add new type
 NLA_BITFIELD_32
Date: Fri, 28 Jul 2017 09:51:41 -0400
Message-ID: <7c17a575-53bb-1f25-4a9a-7418f99660f2@mojatatu.com>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-2-git-send-email-jhs@emojatatu.com>
 <1a2578ca-35c6-884e-1daf-fcc47e5eb618@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: David Ahern <dsahern@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:38426 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751673AbdG1Nvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 09:51:44 -0400
Received: by mail-io0-f194.google.com with SMTP id l7so15074983iof.5
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 06:51:44 -0700 (PDT)
In-Reply-To: <1a2578ca-35c6-884e-1daf-fcc47e5eb618@gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-25 10:41 AM, David Ahern wrote:
> On 7/23/17 7:35 PM, Jamal Hadi Salim wrote:
>> In the most basic form, the user specifies the attribute policy as:
>> [ATTR_GOO] = { .type = NLA_BITFIELD_32, .validation_data = &myvalidflags },
>>
>> where myvalidflags is the bit mask of the flags the kernel understands.
>>
>> If the user _does not_ provide myvalidflags then the attribute will
>> also be rejected.
> 
> No other netlink attribute has this requirement. 

This is the first one where we have to inspect content. We add things
when we need them - as in this case.

> Users of the attributes
> are the only ones that know if a value is valid or not (e.g, attribute
> passing a device index) and those are always checked in line.

It doesnt make sense that every user of the API has to repeat that
validation code. Same principle as someone specifying that a type is
u32 and have the nla validation check it. At some point we never had
the u32 validation code. Then it was factored out because everyone
repeats the same boilerplate code.
I see this in the same spirit.

> Furthermore, you are locking this attribute into a static meaning of
> what is a valid value when flags can be valid or invalid based on other
> attributes passed in the request.
> 

That doesnt disqualify that i factored out common code that all users
of this nltype are going to cutnpaste.

On the dependency on bit presence topic: I had added an "extra
validation" ops - but it was distracting enough that i removed that
patch altogether.

cheers,
jamal
