From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH net-next 1/2] flow_dissector: Cleanup control flow
Date: Fri, 1 Sep 2017 09:12:48 -0700
Message-ID: <CAPDqMer1vQKnyafL45jBA5yaZhRr2jX0=p_jXh9MwTP-jVhbiA@mail.gmail.com>
References: <20170831222239.21509-1-tom@quantonium.net> <20170831222239.21509-2-tom@quantonium.net>
 <87k21izjdc.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        alex.popov@linux.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36503 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751945AbdIAQMv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:12:51 -0400
Received: by mail-wm0-f53.google.com with SMTP id f127so4361035wmf.1
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 09:12:50 -0700 (PDT)
In-Reply-To: <87k21izjdc.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 1, 2017 at 5:35 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Tom Herbert <tom@quantonium.net> writes:
>
>> __skb_flow_dissect is riddled with gotos that make discerning the flow,
>> debugging, and extending the capability difficult. This patch
>> reorganizes things so that we only perform goto's after the two main
>> switch statements (no gotos within the cases now). It also eliminates
>> several goto labels so that there are only two labels that can be target
>> for goto.
>
> The problem with the
>
> fdret = ... ;
> break;
>
> is that we now have to count curly braces to look what break does
> actually break and where fdret is being processed. With the number of
> context lines you send for the patch this is hard to review.
>
> I tend to like the gotos a bit more for now.

This is a step towards a more modular design for flow dissector. The
goto's force a monolithic design and make it hard to implement new
functionality like trying to enforce limits on encapsulation which
requires a single point for logic. The ip, ipv6, and mpls labels were
really unnecessary to begin with, the proto again logic works fine for
those. This is also a segway to breaking up the very large
__skb_flow_dissect function into more manageable components (IP
protocol dissection should be its own function for instance). Follow
on patches will allow protocol specific implementations of flow
dissection located with the rest of the protocol implementation, so
hopefully we can end the practice of adding support for every
networking protocol in one single core function (analogous to how we
parse protocols in GRO).

Tom
