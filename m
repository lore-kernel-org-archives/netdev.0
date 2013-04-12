From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tuntap: fix error return code in tun_set_iff()
Date: Fri, 12 Apr 2013 06:49:20 -0700
Message-ID: <1365774560.4459.26.camel@edumazet-glaptop>
References: <CAPgLHd9WrbgeYH9pw81kQn9sv=On8e399qAOth6MWprF6PS5pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	edumazet@google.com, nhorman@tuxdriver.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:50510 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755074Ab3DLNtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 09:49:23 -0400
Received: by mail-pa0-f52.google.com with SMTP id fb10so1470210pad.25
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 06:49:22 -0700 (PDT)
In-Reply-To: <CAPgLHd9WrbgeYH9pw81kQn9sv=On8e399qAOth6MWprF6PS5pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 21:17 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as returned elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/tun.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index b7c457a..729ed53 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1594,7 +1594,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  
>  		if (tun->flags & TUN_TAP_MQ &&
>  		    (tun->numqueues + tun->numdisabled > 1))
> -			return err;
> +			return -EBUSY;
>  	}
>  	else {
>  		char *name;

Bug added in linux-3.8 , commit 4008e97f866db665 
("tuntap: fix ambigious multiqueue API")

Acked-by: Eric Dumazet <edumazet@google.com>
