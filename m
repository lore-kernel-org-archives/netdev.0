From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 01/13] ixgbe: Add support for IPv6 and UDP to
 ixgbe_get_headlen
Date: Sat, 20 Oct 2012 10:01:10 +0200
Message-ID: <1350720070.13333.359.camel@edumazet-glaptop>
References: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1350714367-24208-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49948 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487Ab2JTIBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 04:01:15 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so429278eek.19
        for <netdev@vger.kernel.org>; Sat, 20 Oct 2012 01:01:14 -0700 (PDT)
In-Reply-To: <1350714367-24208-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-19 at 23:25 -0700, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change adds support for IPv6 and UDP to ixgbe_get_headlen. The
> advantage to this is that we can now handle ipv4/UDP, ipv6/TCP, and
> ipv6/UDP with a single memcpy instead of having to do them in multiple
> pskb_may_pull calls.
> 
> A quick bit of testing shows that we increase throughput for a single
> session of netperf from 8800Mpbs to about 9300Mpbs in the case of ipv6/TCP.
> As such overall ipv6 performance should improve with this change.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Stephen Ko  <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)

Thats pretty interesting.

Why this work is not done generically, so that all drivers can have
benefit of it ?

Even a driver not using fragments could have benefit, because we could
prefetch() so that GRO stack is faster (no stall to get the last 2 bytes
of a TCP header when timestamps are used)

Thanks
