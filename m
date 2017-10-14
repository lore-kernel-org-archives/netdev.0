From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] ipv6: only update __use and lastusetime once per
 jiffy at most
Date: Fri, 13 Oct 2017 17:26:28 -0700
Message-ID: <CANn89i+09PB1=J8mXO495iOK4oe4hsnRF=YsOQQJAsnw5ydeoA@mail.gmail.com>
References: <20171013220807.90366-1-tracywwnj@gmail.com> <20171014000924.dcfuqxwlalaigqdq@kafai-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Wei Wang <weiwan@google.com>, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:45951 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753230AbdJNA0a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 20:26:30 -0400
Received: by mail-qt0-f172.google.com with SMTP id p1so22580786qtg.2
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 17:26:29 -0700 (PDT)
In-Reply-To: <20171014000924.dcfuqxwlalaigqdq@kafai-mbp.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 5:09 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Fri, Oct 13, 2017 at 10:08:07PM +0000, Wei Wang wrote:
>> From: Wei Wang <weiwan@google.com>
>>
>> In order to not dirty the cacheline too often, we try to only update
>> dst->__use and dst->lastusetime at most once per jiffy.
>
>
>> As dst->lastusetime is only used by ipv6 garbage collector, it should
>> be good enough time resolution.
> Make sense.
>
>> And __use is only used in ipv6_route_seq_show() to show how many times a
>> dst has been used. And as __use is not atomic_t right now, it does not
>> show the precise number of usage times anyway. So we think it should be
>> OK to only update it at most once per jiffy.
> If __use is only bumped HZ number of times per second and we can do ~3Mpps now,
> would __use be way off?

It is not used in the kernel, and is not even reported by user space
(iproute2) currently.

With the percpu stuff, we never did the sum anyway.

I believe we should be fine by being very lazy on this field.

If really someones complain, we will see, but insuring ~one update per
HZ seems fine.
