From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH v3 net-next 0/5] ulp: Generalize ULP infrastructure
Date: Tue, 08 Aug 2017 12:30:14 -0700
Message-ID: <598A1146.9090205@gmail.com>
References: <20170807172818.31855-1-tom@quantonium.net> <5989D958.6080506@gmail.com> <CALx6S37HW6VF1ed5RQx7HCNMGM8pRpb54R1OSFHN8mDNpsc1uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>,
        Dave Watson <davejwatson@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37948 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752037AbdHHTa2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 15:30:28 -0400
Received: by mail-pg0-f66.google.com with SMTP id 123so3890959pga.5
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 12:30:28 -0700 (PDT)
In-Reply-To: <CALx6S37HW6VF1ed5RQx7HCNMGM8pRpb54R1OSFHN8mDNpsc1uQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2017 10:04 AM, Tom Herbert wrote:
> On Tue, Aug 8, 2017 at 8:31 AM, John Fastabend <john.fastabend@gmail.com> wrote:
>> On 08/07/2017 10:28 AM, Tom Herbert wrote:
>>> Generalize the ULP infrastructure that was recently introduced to
>>> support kTLS. This adds a SO_ULP socket option and creates new fields in
>>> sock structure for ULP ops and ULP data. Also, the interface allows
>>> additional per ULP parameters to be set so that a ULP can be pushed
>>> and operations started in one shot.
>>>
>>> In this patch set:
>>>   - Minor dependency fix in inet_common.h
>>>   - Implement ULP infrastructure as a socket mechanism
>>>   - Fixes TCP and TLS to use the new method (maintaining backwards
>>>     API compatibility)
>>>   - Adds a ulp.txt document
>>>
>>> Tested: Ran simple ULP. Dave Watson verified kTLS works.
>>>
>>> -v2: Fix compilation errors when CONFIG_ULP_SOCK not set.
>>> -v3: Fix one more build issue, check that sk_protocol is IPPROTO_TCP
>>>      in tsl_init. Also, fix a couple of minor issues related to
>>>      introducing locked versions of sendmsg, send page. Thanks to
>>>      Dave Watson, John Fastabend, and Mat Martineau for testing and
>>>      providing fixes.
>>>
>>
>>
>> Hi Tom, Dave,
>>
>> I'm concerned about the performance impact of walking a list and
>> doing string compares on every socket we create with kTLS. Dave
>> do you have any request/response tests for kTLS that would put pressure
>> on the create/destroy time of this infrastructure? We should do some
>> tests with dummy entries in the ULP list to understand the impact of
>> this list walk.
>>
>> I like the underlying TCP generalized hooks, but do we really expect a
>> lot of these hooks to exist? If we only have two on the roadmap
>> (kTLS and socktap) it seems a bit overkill. Further, if we really expect
>> many ULP objects then the list walk and compare will become more expensive
>> perhaps becoming noticeable in request per second metrics.
>>
>> Why not just create another socktap socketopt? That will be better from
>> complexity and likely performance sides.
>>
> IMO, given that there is at most two even proposed at this point I
> don't there's much point addressing performance. When ULP feature
> catches on and we start see a whole bunch of them then it's
> straightforward to use a hash table or some more efficient mechanism.
> 

OTOH these optimizations are usually easiest to do at the beginning. And
building an enum of ULP types would allow removing string comparisons and
to do simpler unsigned comparisons. I wont complain too much here though
because this series didn't introduce the lists.

> Tom
> 
>> Thanks,
>> .John
>>
