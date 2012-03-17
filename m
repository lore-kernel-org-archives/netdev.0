From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] ipv6: Allocate unique metrics for icmp6
 packets to prevent tainting dst metrics
Date: Sat, 17 Mar 2012 09:36:41 -0700
Message-ID: <1332002201.19406.25.camel@edumazet-glaptop>
References: <4F620DC5.7080607@network-box.com>
	 <20120316.230245.1004014834159539357.davem@davemloft.net>
	 <4F64B203.40307@network-box.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Nick Jones <nick.jones@network-box.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:43103 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040Ab2CQQgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 12:36:45 -0400
Received: by dajr28 with SMTP id r28so7705806daj.19
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 09:36:44 -0700 (PDT)
In-Reply-To: <4F64B203.40307@network-box.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-03-17 at 23:47 +0800, Nick Jones wrote:
> The generation of an icmp6 packet, targeted to a specific desination
> address, will cause the shared metrics of the ip6_dst and inetpeer
> of that address to be tainted with the hoplimit value 255.
> All packets, icmp6 or otherwise, will have this hoplimit value, and
> if the destination is a router, not even advertisements specifying a
> new hoplimit value will have any effect due to the way
> ip6_dst_hoplimit works.
> 
> By allocating a unique metrics array for the icmp6 packet, the shared
> metrics will not be tainted.  A ip6_dst flag is added to indicate that
> the metrics for the dst don't belong to the peer, thus are not unique
> and should be freed when the dst is freed.
> 
> Signed-off-by: Nick Jones <nick.jones@network-box.com>
> ---

> +	}
> +	dst_init_metrics(&rt->dst, metrics, 0);

Dont be fooled by 8e2ec639 precedent, third argument is a bool, so
please use 'false' instead of 0
