From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] ipv6: Do not treat a GSO_TCPV4 request from UDP
 tunnel over IPv6 as invalid
Date: Sun, 23 Nov 2014 14:18:27 -0500 (EST)
Message-ID: <20141123.141827.2053160495446021906.davem@davemloft.net>
References: <20141122033603.22361.28896.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbaKWTS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 14:18:29 -0500
In-Reply-To: <20141122033603.22361.28896.stgit@ahduyck-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Fri, 21 Nov 2014 19:37:09 -0800

> This patch adds SKB_GSO_TCPV4 to the list of supported GSO types handled by
> the IPv6 GSO offloads.  Without this change VXLAN tunnels running over IPv6
> do not currently handle IPv4 TCP TSO requests correctly and end up handing
> the non-segmented frame off to the device.
> 
> Below is the before and after for a simple netperf TCP_STREAM test between
> two endpoints tunneling IPv4 over a VXLAN tunnel running on IPv6 on top of
> a 1Gb/s network adapter.
> 
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.29       0.88      Before
>  87380  16384  16384    10.03     895.69      After
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied, thank you.
