From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH v1 net] TCP_USER_TIMEOUT and tcp_keepalive should conform
 to RFC5482
Date: Wed, 9 Aug 2017 20:32:40 -0700
Message-ID: <CAPshTCjs+Hie6xE6P10iB9ftLfhnpNJd0mEVdtSZ70gT6PVevQ@mail.gmail.com>
References: <CAK6E8=ehu5uK6bsprzAQc-Nu6WS2YQEcktD0H2RrjgPpS47-Yg@mail.gmail.com>
 <CAPshTCgaYVPEbZxDr9sUz7OFibweQn6fwRtP66cgw5eNrHUOWA@mail.gmail.com>
 <CABGNeczGSsL6xj-SkXQYTWXXe+mJoyhvrQxuLkiO27pW0y8MtA@mail.gmail.com>
 <20170809.173032.660035274684914457.davem@davemloft.net> <19024bb3-c06b-d004-5527-e4c54af66003@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, codesoldier1@gmail.com,
        Yuchung Cheng <ycheng@google.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rao Shoaib <rao.shoaib@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:34931 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752623AbdHJDcn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 23:32:43 -0400
Received: by mail-it0-f43.google.com with SMTP id 76so7251521ith.0
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 20:32:42 -0700 (PDT)
In-Reply-To: <19024bb3-c06b-d004-5527-e4c54af66003@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 9, 2017 at 5:47 PM, Rao Shoaib <rao.shoaib@oracle.com> wrote:
>
>
> On 08/09/2017 05:30 PM, David Miller wrote:
>>
>> From: Joe Smith <codesoldier1@gmail.com>
>> Date: Wed, 9 Aug 2017 17:20:32 -0700
>>
>>> Making Linux conform to standards and behavior that is logical seems
>>> like a good enough reason.
>>
>> That's an awesome attitude to have when we're implementing something
>> new and don't have the facility already.
>>
>> But when we have something already the only important consideration is
>> not breaking existing apps which rely on that behavior.
>>
>> That is much, much, more important than standards compliance.
>>
>> If users are confused, just fix the documentation.
>
> David,
>
> If it was just confusion than sure fixing the documentation is fine. What if
> the logic is incorrect, does not conform to the standard that is says it is

Not sure what part of logic is "incorrect" when it was a homegrown Linux API
with no need to conform with any "standard"? Note that the new API was invented
7 years ago not out of need for RFC5482. In fact I initially call the option
TCP_FAILFAST and did not even know the existence of RFC5482 until someone
around the same time proposed a UTO option specifically for RFC5482 and I
thought the two can be combined. (This is roughly the memory I can
recollect so far.)

So you see my focus back then was to devise a "failfast" option whereas RFC5482
was meant for a "failslow" case. I think that explains why I let the
option override
keepalive so a TCP connection can "fail fast" while RFC5482 4.2 tries to prevent
keepalive failure ahead of UTO, favoring "fail slow".

If we start from a clean slate then perhaps one can argue the semantic
either way
but we do not have a clean slate. For that I still slightly favor not
changing the code
because the risk of breakage is definitely non-zero and the issue you're having
seem to be only related to documentation.

Jerry

> implementing and easy to fix with little or no risk of breakage.
>
> The proposed patch changes a feature that no one uses. It also imposes the
> relation ship between keepalive and timeout values that is required by the
> RFC and make sense.
>
> You are the final authority, if you say we should just fix the documentation
> than that is fine.
>
> Shoaib
>
