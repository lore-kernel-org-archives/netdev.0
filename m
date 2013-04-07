From: Ying Xue <ying.xue-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 4/5] tipc: add InfiniBand media type
Date: Sun, 7 Apr 2013 17:07:12 +0800
Message-ID: <51613740.6050501@windriver.com>
References: <1364993010-15515-1-git-send-email-kaber@trash.net> <1364993010-15515-5-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <jon.maloy-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>, <allan.stephens-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1364993010-15515-5-git-send-email-kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> --- a/net/tipc/core.c
> +++ b/net/tipc/core.c
> @@ -82,6 +82,7 @@ static void tipc_core_stop_net(void)
>  {
>  	tipc_net_stop();
>  	tipc_eth_media_stop();
> +	tipc_ib_media_stop();
>  }
>  
>  /**
> @@ -93,8 +94,17 @@ int tipc_core_start_net(unsigned long addr)
>  
>  	tipc_net_start(addr);
>  	res = tipc_eth_media_start();
> -	if (res)
> -		tipc_core_stop_net();
> +	if (res < 0)
> +		goto err1;
> +	res = tipc_ib_media_start();
> +	if (res < 0)
> +		goto err2;
> +	return res;
> +
> +err2:
> +	tipc_eth_media_stop();

Why do we need to call tipc_eth_media_stop() separately?
In any failed case, we will finally invoke tipc_core_stop_net() which
already places tipc_eth_media_stop().

> +err1:
> +	tipc_core_stop_net();
>  	return res;
>  }
>  

Regards,
Ying
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
