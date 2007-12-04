From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/4] netns: Tag the network flow with the network
 namespace it is in (v2)
Date: Tue, 4 Dec 2007 06:26:05 -0800
Message-ID: <20071204062605.508cf812@shemminger-laptop>
References: <20071204095333.GA6029@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, devel@openvz.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48100 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752779AbXLDO0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 09:26:55 -0500
In-Reply-To: <20071204095333.GA6029@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Dec 2007 12:53:33 +0300
"Denis V. Lunev" <den@openvz.org> wrote:

> As well as marking flows this indirectly marks the ipv4 routing cache
> as every routing entry contains a flow.
> 
> It is useful to add the network namespace into flows as frequently
> the routing information for ingoing and outgoing network packets is
> collected into a flow structure which is then used for several functions
> as it sorts out what is going on.
> 
> Changes from v1:
> - remove flow.h dependency from net_namespace.h
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  include/net/flow.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/flow.h b/include/net/flow.h
> index af59fa5..9590bbe 100644
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
> @@ -10,7 +10,9 @@
>  #include <linux/in6.h>
>  #include <asm/atomic.h>
>  
> +struct net;
>  struct flowi {
> +	struct net *fl_net;
>  	int	oif;
>  	int	iif;
>  	__u32	mark;
> -- 

Can this be made conditional on network namespaces being configured on?
That way the flow structure won't have to grow taking more space.
It matters in DoS attacks where flow cache becomes a critical resource.
