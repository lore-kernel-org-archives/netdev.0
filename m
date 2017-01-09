From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] net: optimize ICMP-reply code path
Date: Mon, 09 Jan 2017 15:49:30 -0500 (EST)
Message-ID: <20170109.154930.276298040600798208.davem@davemloft.net>
References: <20170109150246.30215.63371.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        xiyou.wangcong@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50454 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932130AbdAIUtc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 15:49:32 -0500
In-Reply-To: <20170109150246.30215.63371.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 09 Jan 2017 16:03:59 +0100

> This patchset is optimizing the ICMP-reply code path, for ICMP packets
> that gets rate limited. A remote party can easily trigger this code
> path by sending packets to port number with no listening service.
> 
> Generally the patchset moves the sysctl_icmp_msgs_per_sec ratelimit
> checking to earlier in the code path and removes an allocation.
> 
> 
> Use-case: The specific case I experienced this being a bottleneck is,
> sending UDP packets to a port with no listener, which obviously result
> in kernel replying with ICMP Destination Unreachable (type:3), Port
> Unreachable (code:3), which cause the bottleneck.
> 
>  After Eric and Paolo optimized the UDP socket code, the kernels PPS
> processing capabilities is lower for no-listen ports, than normal UDP
> sockets.  This is bad for capacity planning when restarting a service.
> 
> UDP no-listen benchmark 8xCPUs using pktgen_sample04_many_flows.sh:
>  Baseline: 6.6 Mpps
>  Patch:   14.7 Mpps
> Driver mlx5 at 50Gbit/s.

Series applied, thanks Jesper!
