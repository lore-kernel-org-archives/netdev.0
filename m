From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 1/3] ipv6: fix route cache dump
Date: Tue, 17 Oct 2017 11:41:34 -0700
Message-ID: <CANn89iK867x7NSoLbDC55CnZg2DHhLc-=pvNQAD3W6hRqiu+Fw@mail.gmail.com>
References: <cover.1508261949.git.pabeni@redhat.com> <e54ccbb0c97570a8c1a9c97a3c7bc8a910f02083.1508261949.git.pabeni@redhat.com>
 <CAEA6p_DRZA4aHW-Rxb7kJnwhPAy9HqDzY1nQgFGjCwNeVmTfJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Paolo Abeni <pabeni@redhat.com>, Martin KaFai Lau <kafai@fb.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:50498 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760309AbdJQSlg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 14:41:36 -0400
Received: by mail-qt0-f171.google.com with SMTP id f15so5676833qtf.7
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 11:41:35 -0700 (PDT)
In-Reply-To: <CAEA6p_DRZA4aHW-Rxb7kJnwhPAy9HqDzY1nQgFGjCwNeVmTfJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 11:26 AM, Wei Wang <weiwan@google.com> wrote:
> On Tue, Oct 17, 2017 at 10:40 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>> After the commit 2b760fcf5cfb ("ipv6: hook up exception table to
>> store dst cache"), entries in the routing cache are not shown by:
>>
>> ip route show cache
>
> Hi Paolo,
>
> Thanks for doing this.
> But I think your patch does not take care of the case where there are
> a lot of cached routes in the exception table and 1 skb is just not
> enough to dump the main route + all cached routes in the exception
> table.
> In this case, your patch will keep dumping the same main route.
>
> I think some logic needs to be incorporated into the fib6_walk() so
> that it can also remember the last dumped cached route if necessary in
> the exception table and start from there for the next dump.
> I do have a patch for that and that patch tries to keep a linked list
> of all cached routes from the exception table in the walker struct and
> remove any routes that are already dumped.
> It is a bit complicated and might not be the best solution. And as
> IPv4 already does not support dumping cached routes, I did not send
> that out in the previous patch series.

Yes, since we no longer dump IPV4 cached routes, I doubt anyone
depends on IPv6 cached routes, but not on IPv4 ones.

Paolo, do you have a concrete use case for this ?
