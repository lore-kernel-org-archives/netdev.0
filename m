From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Can not send icmp netunreach packet
Date: Tue, 26 Feb 2008 07:35:38 +0000
Message-ID: <20080226073538.GA4101@ff.dom.local>
References: <47C3B2D9.9090601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, swhiteho@redhat.com, netdev@vger.kernel.org
To: Li Yewang <lyw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:4976 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbYBZHeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 02:34:37 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1146409ugc.16
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2008 23:34:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47C3B2D9.9090601@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-02-2008 07:34, Li Yewang wrote:
> Hi All
> 
>    There is a bug about icmp netunreach.
>    If the kernel does not find a route for a packet, 
>    it must send a icmp netunreach packet to the source host, 
>    and  discard  the packet. But the  kernel  does not send 
>    a icmp netunreach packet because of the  fib_lookup
>    return value  of -ESRCH when a route  is not found. 

...or because some function doesn't handle -ESRCH return from
fib_lookup? It seems changing this to -ESRCH was needed in some cases.
And you don't explain enough why it can't be handled later (like in
ipv4/route.c: ip_route_input_slow)?

Regards,
Jarek P.

> 
> Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>
> 
> diff -Nurp net/core_back/fib_rules.c net/core/fib_rules.c
> --- net/core_back/fib_rules.c   2008-02-25 13:15:37.000000000 +0800
> +++ net/core/fib_rules.c        2008-02-25 13:16:01.000000000 +0800
> @@ -188,7 +188,7 @@ jumped:
>  		}
>  	}
>  
> -	err = -ESRCH;
> +	err = -ENETUNREACH;
>  out:
>  	rcu_read_unlock();
> 
