From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: Add sysctl to toggle early demux for
 tcp and udp
Date: Fri, 10 Mar 2017 16:22:22 -0800
Message-ID: <1489191742.28631.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489116660-4244-1-git-send-email-subashab@codeaurora.org>
         <CALx6S360Y3tmKMHVMUEuRKCskuwXi+9JBfce6WiSpko1sHj=Yg@mail.gmail.com>
         <674d67f5d76f761f3e872dff274a8bda@codeaurora.org>
         <CALx6S340TYEFDAbQfG6X4P0tPJWvyxyXpnLgp9JY7UoBuPEJVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev-owner@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35488 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755129AbdCKAWZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 19:22:25 -0500
In-Reply-To: <CALx6S340TYEFDAbQfG6X4P0tPJWvyxyXpnLgp9JY7UoBuPEJVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-10 at 08:33 -0800, Tom Herbert wrote:

> Okay, now I'm confused. You're saying that when early demux was added
> for IPv6 performance improved, but this patch is allowing early demux
> to be disabled on the basis that it hurts performance for unconnected
> UDP workloads. While it's true that early demux in the case results in
> another UDP lookup, Eric's changes to make it lockless have made that
> lookup very cheap. So we really need numbers to justify this patch.
> 

Fact that the lookup is lockless does not avoid a cache line miss.

Early demux computes a hash based on the 4-tuple, and lookups a hash
table with does not fit in cpu caches.

A cache line miss per packet is expensive, when handling millions of UDP
packets per second, (with millions of 4-tuples)

> Even if the numbers were to show a benefit, we still have the problem
> that this creates a bimodal performance characteristic, e.g. what if
> the work load were 1/2 connected and 1/2 unconnected in real life, or
> what it the user incorrectly guesses the actual workload. Maybe a
> deeper solution to investigate is making early demux work with
> unconnected sockets.

Sure, but forcing all UDP applications to perform IP early demux is not
better.
