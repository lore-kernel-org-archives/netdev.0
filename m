From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v3 net-next 0/5] ulp: Generalize ULP infrastructure
Date: Tue, 8 Aug 2017 10:04:38 -0700
Message-ID: <CALx6S37HW6VF1ed5RQx7HCNMGM8pRpb54R1OSFHN8mDNpsc1uQ@mail.gmail.com>
References: <20170807172818.31855-1-tom@quantonium.net> <5989D958.6080506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>,
        Dave Watson <davejwatson@fb.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37881 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752092AbdHHREk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 13:04:40 -0400
Received: by mail-wm0-f51.google.com with SMTP id t201so12305333wmt.0
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 10:04:39 -0700 (PDT)
In-Reply-To: <5989D958.6080506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 8, 2017 at 8:31 AM, John Fastabend <john.fastabend@gmail.com> wrote:
> On 08/07/2017 10:28 AM, Tom Herbert wrote:
>> Generalize the ULP infrastructure that was recently introduced to
>> support kTLS. This adds a SO_ULP socket option and creates new fields in
>> sock structure for ULP ops and ULP data. Also, the interface allows
>> additional per ULP parameters to be set so that a ULP can be pushed
>> and operations started in one shot.
>>
>> In this patch set:
>>   - Minor dependency fix in inet_common.h
>>   - Implement ULP infrastructure as a socket mechanism
>>   - Fixes TCP and TLS to use the new method (maintaining backwards
>>     API compatibility)
>>   - Adds a ulp.txt document
>>
>> Tested: Ran simple ULP. Dave Watson verified kTLS works.
>>
>> -v2: Fix compilation errors when CONFIG_ULP_SOCK not set.
>> -v3: Fix one more build issue, check that sk_protocol is IPPROTO_TCP
>>      in tsl_init. Also, fix a couple of minor issues related to
>>      introducing locked versions of sendmsg, send page. Thanks to
>>      Dave Watson, John Fastabend, and Mat Martineau for testing and
>>      providing fixes.
>>
>
>
> Hi Tom, Dave,
>
> I'm concerned about the performance impact of walking a list and
> doing string compares on every socket we create with kTLS. Dave
> do you have any request/response tests for kTLS that would put pressure
> on the create/destroy time of this infrastructure? We should do some
> tests with dummy entries in the ULP list to understand the impact of
> this list walk.
>
> I like the underlying TCP generalized hooks, but do we really expect a
> lot of these hooks to exist? If we only have two on the roadmap
> (kTLS and socktap) it seems a bit overkill. Further, if we really expect
> many ULP objects then the list walk and compare will become more expensive
> perhaps becoming noticeable in request per second metrics.
>
> Why not just create another socktap socketopt? That will be better from
> complexity and likely performance sides.
>
IMO, given that there is at most two even proposed at this point I
don't there's much point addressing performance. When ULP feature
catches on and we start see a whole bunch of them then it's
straightforward to use a hash table or some more efficient mechanism.

Tom

> Thanks,
> .John
>
