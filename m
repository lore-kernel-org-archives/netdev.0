From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp6: fix socket leak on early demux
Date: Sat, 29 Jul 2017 14:19:43 -0700 (PDT)
Message-ID: <20170729.141943.1705828011017202803.davem@davemloft.net>
References: <714e32ad7eb21b0b791ecc314cfcc16765c96cd9.1501159497.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, CFSworks@gmail.com,
        mh+netdev@zugschlus.de, subashab@codeaurora.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42094 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751634AbdG2VTo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 17:19:44 -0400
In-Reply-To: <714e32ad7eb21b0b791ecc314cfcc16765c96cd9.1501159497.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 27 Jul 2017 14:45:09 +0200

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

Applied.
