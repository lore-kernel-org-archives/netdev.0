From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH net-next 09/14] gtp: Allow configuring GTP interface as standalone
Date: Wed, 20 Sep 2017 09:24:07 -0700
Message-ID: <CAPDqMeq1tLi=NkLyqma2OEHQi-fYEYeTU-8th9WKoZaeWiM0Rw@mail.gmail.com>
References: <20170919003904.5124-1-tom@quantonium.net> <20170919003904.5124-10-tom@quantonium.net>
 <a6d1dad0-e922-2913-d4c8-592d403ee1cb@tpip.net> <CALx6S3771X4QUm2mJG=aJJ0f4Tm98NpGA7060vF1P8iuCPgicQ@mail.gmail.com>
 <56e339a8-fa2d-6f8d-a89c-c0f3f242763a@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Harald Welte <laforge@gnumonks.org>,
        Rohit Seth <rohit@quantonium.net>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:46974 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdITQYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 12:24:09 -0400
Received: by mail-wm0-f54.google.com with SMTP id i189so8786497wmf.1
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 09:24:08 -0700 (PDT)
In-Reply-To: <56e339a8-fa2d-6f8d-a89c-c0f3f242763a@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 9:07 AM, Andreas Schultz <aschultz@tpip.net> wrote:
>
>
> On 20/09/17 17:57, Tom Herbert wrote:
>>
>> On Wed, Sep 20, 2017 at 8:27 AM, Andreas Schultz <aschultz@tpip.net>
>> wrote:
>>>
>>> On 19/09/17 02:38, Tom Herbert wrote:
>>>>
>>>>
>>>> Add new configuration of GTP interfaces that allow specifying a port to
>>>> listen on (as opposed to having to get sockets from a userspace control
>>>> plane). This allows GTP interfaces to be configured and the data path
>>>> tested without requiring a GTP-C daemon.
>>>
>>>
>>>
>>> This would imply that you can have multiple independent GTP sockets on
>>> the
>>> same IP address.That is not permitted by the GTP specifications. 3GPP TS
>>> 29.281, section 4.3 states clearly that there is "only" one GTP entity
>>> per
>>> IP address.A PDP context is defined by the destination IP and the TEID.
>>> The
>>> destination port is not part of the identity of a PDP context.
>>>
>> We are in no way trying change GTP, if someone runs this in a real GTP
>> network then they need to abide by the specification. However, there
>> is nothing inconsistent and it breaks nothing if someone wishes to use
>> different port numbers in their own private network for testing or
>> development purposes. Every other UDP application that has assigned
>> port number allows configurable ports, I don't see that GTP is so
>> special that it should be an exception.
>
>
> GTP isn't special, I just don't like to have testing only features in there
> when the same goal can be reached without having to add extra stuff. Adding
> code that is not going to be useful in real production setups (or in this
> case would even break production setups when enabled accidentally) makes the
> implementation more complex than it needs to be.

Well, you could make the same argument that allowing GTP to configured
as standalone interface is a problem since GTP is only allowed to be
with used with GTP-C. But, then we have something in the kernel that
the community is expected to support, but requires jumping through a
whole bunch of hoops just to run a simple netperf. The more that
patches and features look like other things in the kernel that are
already well established, the better the chances we can accept them
and support them. It's probably a natural consequence of any large
open source project, so sometimes it's worth the effort to add a few
lines of complexity to get the benefits of community contribution and
support.

Tom
