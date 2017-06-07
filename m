From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next v2 3/3] udp: try to avoid 2 cache miss on
 dequeue
Date: Wed, 07 Jun 2017 09:56:45 +0200
Message-ID: <1496822205.2409.1.camel@redhat.com>
References: <cover.1496756090.git.pabeni@redhat.com>
         <cdbe7b4e6758719d3e02938f05c8575d009e2822.1496756090.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49504 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751026AbdFGH4s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 03:56:48 -0400
In-Reply-To: <cdbe7b4e6758719d3e02938f05c8575d009e2822.1496756090.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, 2017-06-06 at 16:23 +0200, Paolo Abeni wrote:
> when udp_recvmsg() is executed, on x86_64 and other archs, most skb
> fields are on cold cachelines.
> If the skb are linear and the kernel don't need to compute the udp
> csum, only a handful of skb fields are required by udp_recvmsg().
> Since we already use skb->dev_scratch to cache hot data, and
> there are 32 bits unused on 64 bit archs, use such field to cache
> as much data as we can, and try to prefetch on dequeue the relevant
> fields that are left out.
> 
> This can save up to 2 cache miss per packet.
> 
> v1 -> v2:
>   - changed udp_dev_scratch fields types to u{32,16} variant,
>     replaced bitfield with bool
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Can you please keep on-hold this series a little time? the lkp-robot
just reported a performance regression on v1 which I have still to
investigate. I can't look at it really soon, but I expect the same
should apply to v2.

It sounds quite weird to me, since the bisected patch touches the UDP
code only and the regression is on apachebench.

Thank you,

Paolo
