From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] ip_tunnel: Report Rx dropped in
 ip_tunnel_get_stats64
Date: Thu, 14 May 2015 13:56:34 -0700
Message-ID: <1431636994.27831.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150514200454.1537.43655.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:34449 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932953AbbENU4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 16:56:37 -0400
Received: by qkgx75 with SMTP id x75so58140050qkg.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 13:56:36 -0700 (PDT)
In-Reply-To: <20150514200454.1537.43655.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 13:04 -0700, Alexander Duyck wrote:
> The rx_dropped stat wasn't being reported when ip_tunnel_get_stats64 was
> called.  This was leading to some confusing results in my debug as I was
> seeing rx_errors increment but no other value which pointed me toward the
> type of error being seen.
> 
> This change corrects that by copying the value over from
> dev->stats.rx_dropped inot tot->rx_dropped.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  net/ipv4/ip_tunnel_core.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
> index 3998b1822d85..a6a980680b8a 100644
> --- a/net/ipv4/ip_tunnel_core.c
> +++ b/net/ipv4/ip_tunnel_core.c
> @@ -191,6 +191,7 @@ struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
>  	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
>  	tot->rx_length_errors = dev->stats.rx_length_errors;
>  	tot->rx_frame_errors = dev->stats.rx_frame_errors;
> +	tot->rx_dropped = dev->stats.rx_dropped;
>  	tot->rx_errors = dev->stats.rx_errors;
>  
>  	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;

Or use netdev_stats_to_stats64() to remove all these copies, as we
obviously can miss some of them.

-> reduce code size.
