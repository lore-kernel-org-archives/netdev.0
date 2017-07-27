From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp6: fix socket leak on early demux
Date: Thu, 27 Jul 2017 06:35:39 -0700
Message-ID: <1501162539.12695.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <714e32ad7eb21b0b791ecc314cfcc16765c96cd9.1501159497.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Sam Edwards <CFSworks@gmail.com>,
        Marc Haber <mh+netdev@zugschlus.de>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:38122 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751533AbdG0Nfn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 09:35:43 -0400
Received: by mail-wr0-f170.google.com with SMTP id f21so87331648wrf.5
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 06:35:43 -0700 (PDT)
In-Reply-To: <714e32ad7eb21b0b791ecc314cfcc16765c96cd9.1501159497.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-07-27 at 14:45 +0200, Paolo Abeni wrote:
> When an early demuxed packet reaches __udp6_lib_lookup_skb(), the
> sk reference is retrieved and used, but the relevant reference
> count is leaked and the socket destructor is never called.
> Beyond leaking the sk memory, if there are pending UDP packets
> in the receive queue, even the related accounted memory is leaked.
> 
> In the long run, this will cause persistent forward allocation errors
> and no UDP skbs (both ipv4 and ipv6) will be able to reach the
> user-space.
> 
> Fix this by explicitly accessing the early demux reference before
> the lookup, and properly decreasing the socket reference count
> after usage.
> 
> Also drop the skb_steal_sock() in __udp6_lib_lookup_skb(), and
> the now obsoleted comment about "socket cache".
> 
> The newly added code is derived from the current ipv4 code for the
> similar path.
> 
> v1 -> v2:
>   fixed the __udp6_lib_rcv() return code for resubmission,
>   as suggested by Eric
> 
> Reported-by: Sam Edwards <CFSworks@gmail.com>
> Reported-by: Marc Haber <mh+netdev@zugschlus.de>
> Fixes: 5425077d73e0 ("net: ipv6: Add early demux handler for UDP unicast")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
