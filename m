From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/3] dev: Prevent creating network devices with negative
 ifindex
Date: Fri, 16 Jun 2017 09:18:06 -0700
Message-ID: <20170616091806.2dd229e2@xeon-e3>
References: <cover.1497621810.git.serhe.popovych@gmail.com>
        <d365b6f06598d041a177b91b15929285c2649935.1497621810.git.serhe.popovych@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Serhey Popovych <serhe.popovych@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33821 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbdFPQSN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 12:18:13 -0400
Received: by mail-pg0-f51.google.com with SMTP id v18so22374762pgb.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 09:18:13 -0700 (PDT)
In-Reply-To: <d365b6f06598d041a177b91b15929285c2649935.1497621810.git.serhe.popovych@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Jun 2017 17:23:51 +0300
Serhey Popovych <serhe.popovych@gmail.com> wrote:

> Interface index is signed integer, we can pass ifm->ifi_index
> from userspace via netlink and create network device with
> negative ifindex value.
> 
> Fixes: 9c7dafbfab15 ("net: Allow to create links with given ifindex")
> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
> ---
>  net/core/dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8658074..dae8010 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -7491,7 +7491,7 @@ int register_netdevice(struct net_device *dev)
>  	}
>  
>  	ret = -EBUSY;
> -	if (!dev->ifindex)
> +	if (dev->ifindex <= 0)
>  		dev->ifindex = dev_new_index(net);
>  	else if (__dev_get_by_index(net, dev->ifindex))
>  		goto err_uninit;

You should fix this by adding error check in the netlink portion
that allows creating devices with given ifindex. Passing < 0
should be an error.
