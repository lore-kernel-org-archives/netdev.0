From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2] net: Add sysctl to toggle early demux for tcp
 and udp
Date: Fri, 10 Mar 2017 08:33:58 -0800
Message-ID: <CALx6S340TYEFDAbQfG6X4P0tPJWvyxyXpnLgp9JY7UoBuPEJVA@mail.gmail.com>
References: <1489116660-4244-1-git-send-email-subashab@codeaurora.org>
 <CALx6S360Y3tmKMHVMUEuRKCskuwXi+9JBfce6WiSpko1sHj=Yg@mail.gmail.com> <674d67f5d76f761f3e872dff274a8bda@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev-owner@vger.kernel.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35464 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755383AbdCJQeA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 11:34:00 -0500
Received: by mail-qk0-f195.google.com with SMTP id o135so28448588qke.2
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 08:33:59 -0800 (PST)
In-Reply-To: <674d67f5d76f761f3e872dff274a8bda@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 9, 2017 at 9:26 PM, Subash Abhinov Kasiviswanathan
<subashab@codeaurora.org> wrote:
> On 2017-03-09 20:42, Tom Herbert wrote:
>>
>> On Thu, Mar 9, 2017 at 7:31 PM, Subash Abhinov Kasiviswanathan
>> <subashab@codeaurora.org> wrote:
>>>
>>> Certain system process significant unconnected UDP workload.
>>> It would be preferrable to disable UDP early demux for those systems
>>> and enable it for TCP only.
>>>
>> Presumably you want this for performance reasons. Can you provide some
>> before and after numbers?
>
>
> Hi Tom
>
> We are working on UDPv6 performance issues seen on an Android ARM64 system.
> Adding an early demux handler (link below) for it helped to increase
> performance
> (800Mbps -> 870Mbps). This helps because Android statistics rules do
> multiple
> socket lookup when no socket is associated with the skb.
>
> https://www.mail-archive.com/netdev@vger.kernel.org/msg157003.html
>
> Eric mentioned that server loads usually see more unconnected load and he
> preferred to turn off early demux for UDP, hence this patch. I don't have
> numbers
> for unconnected loads as of now though.
>
Subash,

Okay, now I'm confused. You're saying that when early demux was added
for IPv6 performance improved, but this patch is allowing early demux
to be disabled on the basis that it hurts performance for unconnected
UDP workloads. While it's true that early demux in the case results in
another UDP lookup, Eric's changes to make it lockless have made that
lookup very cheap. So we really need numbers to justify this patch.

Even if the numbers were to show a benefit, we still have the problem
that this creates a bimodal performance characteristic, e.g. what if
the work load were 1/2 connected and 1/2 unconnected in real life, or
what it the user incorrectly guesses the actual workload. Maybe a
deeper solution to investigate is making early demux work with
unconnected sockets.

Tom

> --
> Qualcomm Innovation Center, Inc.
> The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a
> Linux Foundation Collaborative Project
