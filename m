From: Rao Shoaib <rao.shoaib@oracle.com>
Subject: Re: [PATCH v1 net] TCP_USER_TIMEOUT and tcp_keepalive should conform
 to RFC5482
Date: Thu, 10 Aug 2017 14:05:37 -0700
Message-ID: <3c707f1e-eae8-1385-49cf-aab59798756a@oracle.com>
References: <CAK6E8=ehu5uK6bsprzAQc-Nu6WS2YQEcktD0H2RrjgPpS47-Yg@mail.gmail.com>
 <CAPshTCgaYVPEbZxDr9sUz7OFibweQn6fwRtP66cgw5eNrHUOWA@mail.gmail.com>
 <CABGNeczGSsL6xj-SkXQYTWXXe+mJoyhvrQxuLkiO27pW0y8MtA@mail.gmail.com>
 <20170809.173032.660035274684914457.davem@davemloft.net>
 <19024bb3-c06b-d004-5527-e4c54af66003@oracle.com>
 <CAPshTCjs+Hie6xE6P10iB9ftLfhnpNJd0mEVdtSZ70gT6PVevQ@mail.gmail.com>
 <CAPshTChOnTb8HyRfS5cqjcTjUCpHRvMMuG8WNgLTuhT9Z=+3qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, codesoldier1@gmail.com,
        Yuchung Cheng <ycheng@google.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31730 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752942AbdHJVGY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 17:06:24 -0400
In-Reply-To: <CAPshTChOnTb8HyRfS5cqjcTjUCpHRvMMuG8WNgLTuhT9Z=+3qA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/09/2017 09:59 PM, Jerry Chu wrote:
> On Wed, Aug 9, 2017 at 8:32 PM, Jerry Chu <hkchu@google.com> wrote:
>> On Wed, Aug 9, 2017 at 5:47 PM, Rao Shoaib <rao.shoaib@oracle.com> wrote:
>>>
>>> On 08/09/2017 05:30 PM, David Miller wrote:
>>>> From: Joe Smith <codesoldier1@gmail.com>
>>>> Date: Wed, 9 Aug 2017 17:20:32 -0700
>>>>
>>>>> Making Linux conform to standards and behavior that is logical seems
>>>>> like a good enough reason.
>>>> That's an awesome attitude to have when we're implementing something
>>>> new and don't have the facility already.
>>>>
>>>> But when we have something already the only important consideration is
>>>> not breaking existing apps which rely on that behavior.
>>>>
>>>> That is much, much, more important than standards compliance.
>>>>
>>>> If users are confused, just fix the documentation.
>>> David,
>>>
>>> If it was just confusion than sure fixing the documentation is fine. What if
>>> the logic is incorrect, does not conform to the standard that is says it is
>> Not sure what part of logic is "incorrect" when it was a homegrown Linux API
>> with no need to conform with any "standard"? Note that the new API was invented
>> 7 years ago not out of need for RFC5482. In fact I initially call the option
>> TCP_FAILFAST and did not even know the existence of RFC5482 until someone
>> around the same time proposed a UTO option specifically for RFC5482 and I
>> thought the two can be combined. (This is roughly the memory I can
>> recollect so far.)
>>
>> So you see my focus back then was to devise a "failfast" option whereas RFC5482
>> was meant for a "failslow" case. I think that explains why I let the
>> option override
>> keepalive so a TCP connection can "fail fast" while RFC5482 4.2 tries to prevent
>> keepalive failure ahead of UTO, favoring "fail slow".
>>
>> If we start from a clean slate then perhaps one can argue the semantic
>> either way
>> but we do not have a clean slate. For that I still slightly favor not
>> changing the code
>> because the risk of breakage is definitely non-zero and the issue you're having
>> seem to be only related to documentation.
We all make mistakes and over look things, that seems to be the case 
here. If this was so important than I am sure there was a use case. None 
has been presented. Without a use case I do not understand why we have 
to live with broken logic when we have a chance to fix it and make the 
code better.

If this change does break something (very very unlikely) we will 
understand the use case and provide an appropriate solution.

> One more thing - the proposed patch compares TCP_KEEPIDLE against
> TCP_USER_TIMEOUT. But I don't think TCP_KEEPIDLE is what the
> "keep-alive
> timer" referred to in RFC5482. Linux keepalive implementation seems to use #
> of retries (TCP_KEEPCNT) rather than time duration (keep-alive time) to
> determine when to quit. If that is the case then your proposed change is not
> fully "compliant" either and the best is probably just don't change.
Did you look at the patch and what it changes ?

Take a look at the TCP_KEEPIDLE socket option and see what it does or 
just look at the man page of tcp(7)

TCP_KEEPIDLE (since Linux 2.4) The time (in seconds) the connection 
needs to remain idle before TCP starts sending keepalive probes, if the 
socket option SO_KEEPALIVE has been set on this socket. This option 
should not be used in code intended to be portable.

Shoaib.
>
>> Jerry
>>
>>> implementing and easy to fix with little or no risk of breakage.
>>>
>>> The proposed patch changes a feature that no one uses. It also imposes the
>>> relation ship between keepalive and timeout values that is required by the
>>> RFC and make sense.
>>>
>>> You are the final authority, if you say we should just fix the documentation
>>> than that is fine.
>>>
>>> Shoaib
>>>
