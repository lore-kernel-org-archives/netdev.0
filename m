From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] [NET]: Add per-connection option to set max TSO frame
 size
Date: Tue, 12 Feb 2008 21:22:18 -0800
Message-ID: <20080212212218.5eb7d121@extreme>
References: <20080212220132.8446.88493.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:52705 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbYBMFWf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 00:22:35 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JPA4h-0006C2-Lj
	for netdev@vger.kernel.org; Wed, 13 Feb 2008 05:22:27 +0000
Received: from 75-175-36-245.ptld.qwest.net ([75.175.36.245])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 05:22:27 +0000
Received: from shemminger by 75-175-36-245.ptld.qwest.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 05:22:27 +0000
In-Reply-To: <20080212220132.8446.88493.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Feb 2008 14:01:32 -0800
PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com> wrote:

> This patch adds the ability for device drivers to control the size of the
> TSO frames being sent to them, per TCP connection.  By setting the
> netdevice's max_gso_frame_size value, the socket layer will set the GSO
> frame size based on that value.  This will propogate into the TCP layer,
> and send TSO's of that size to the hardware.
> 
> This can be desirable to help tune the bursty nature of TSO on a
> per-adapter basis, where one may have 1 GbE and 10 GbE devices coexisting
> in a system, one running multiqueue and the other not, etc.
> 
> This can also be desirable for devices that cannot support full 64 KB
> TSO's, but still want to benefit from some level of segmentation
> offloading.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> ---
> 
>  include/linux/netdevice.h |    6 ++++++
>  include/net/sock.h        |    2 ++
>  net/core/dev.c            |    1 +
>  net/core/sock.c           |    6 ++++--
>  net/ipv4/tcp_output.c     |    4 ++--
>  5 files changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 047d432..ed1cc32 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -616,6 +616,7 @@ struct net_device
>  
>  	/* Partially transmitted GSO packet. */
>  	struct sk_buff		*gso_skb;
> +	int			max_gso_frame_size;

should use unsigned rather than int (yes the older code is sloppy).

Also what about IPV6? 
-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>


