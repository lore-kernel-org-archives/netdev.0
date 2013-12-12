From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Cache route in IP tunnels
Date: Wed, 11 Dec 2013 23:37:18 -0800
Message-ID: <1386833838.19078.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1312112207400.27914@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:56132 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255Ab3LLHhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 02:37:21 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so32303pbb.30
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 23:37:20 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1312112207400.27914@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-11 at 22:17 -0800, Tom Herbert wrote:
> Avoid doing a route lookup on every packet being tunneled.
> 
> In ip_tunnel.c cache the route returned from ip_route_output if
> the tunnel is "connected", that is all the routing parameters are
> taken from tunnel parms for a packet. Specifically, not NBMA tunnel
> and tos is from tunnel parms (not inner packet).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

Replacing per cpu dst (nh_pcpu_rth_output) with a single shared dst is
not going to be better on SMP.

Do you have any performance data using multiqueue NIC, with say 32 cpus
and 32 TX queues ?

I suspect a high false sharing on dst refcount.

Thanks
