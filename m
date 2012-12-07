From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next PATCH] tun: correctly report an error in tun_flow_init()
Date: Fri, 07 Dec 2012 13:51:47 +0800
Message-ID: <3078848.lXJIGSkO7f@jason-thinkpad-t430s>
References: <20121206154838.6073.17102.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45564 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752139Ab2LGFvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 00:51:50 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qB75pobi019125
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2012 00:51:50 -0500
In-Reply-To: <20121206154838.6073.17102.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, December 06, 2012 10:48:38 AM Paul Moore wrote:
> On error, the error code from tun_flow_init() is lost inside
> tun_set_iff(), this patch fixes this by assigning the tun_flow_init()
> error code to the "err" variable which is returned by
> the tun_flow_init() function on error.
> 
> Signed-off-by: Paul Moore <pmoore@redhat.com>

Acked-by: Jason Wang <jasowang@redhat.com>

Thanks Paul.
> ---
>  drivers/net/tun.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index a1b2389..14a0454 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1591,7 +1591,8 @@ static int tun_set_iff(struct net *net, struct file
> *file, struct ifreq *ifr)
> 
>  		tun_net_init(dev);
> 
> -		if (tun_flow_init(tun))
> +		err = tun_flow_init(tun);
> +		if (err < 0)
>  			goto err_free_dev;
> 
>  		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
