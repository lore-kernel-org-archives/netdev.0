From: Neil Horman <nhorman@redhat.com>
Subject: Re: [PATCH] Revert "netpoll: Fix extra refcount release in
 netpoll_cleanup()"
Date: Wed, 6 Apr 2016 09:48:37 -0400
Message-ID: <20160406134837.GD1955@hmsreliant.think-freely.org>
References: <20160405205822.24724.95522.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Duyck <aduyck@mirantis.com>,
	Bart Van Assche <bart.vanassche@sandisk.com>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751187AbcDFNsk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 09:48:40 -0400
Content-Disposition: inline
In-Reply-To: <20160405205822.24724.95522.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2016 at 03:58:22PM -0500, Bjorn Helgaas wrote:
> This reverts commit 543e3a8da5a4c453e992d5351ef405d5e32f27d7.
> 
> Direct callers of __netpoll_setup() depend on it to set np->dev,
> so we can't simply move that assignment up to netpoll_stup().
> 
> Reported-by: Bart Van Assche <bart.vanassche@sandisk.com>
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> ---
>  net/core/netpoll.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index a57bd17..94acfc8 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -603,6 +603,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
>  	const struct net_device_ops *ops;
>  	int err;
>  
> +	np->dev = ndev;
>  	strlcpy(np->dev_name, ndev->name, IFNAMSIZ);
>  	INIT_WORK(&np->cleanup_work, netpoll_async_cleanup);
>  
> @@ -669,7 +670,6 @@ int netpoll_setup(struct netpoll *np)
>  		goto unlock;
>  	}
>  	dev_hold(ndev);
> -	np->dev = ndev;
>  
>  	if (netdev_master_upper_dev_get(ndev)) {
>  		np_err(np, "%s is a slave device, aborting\n", np->dev_name);
> @@ -770,7 +770,6 @@ int netpoll_setup(struct netpoll *np)
>  	return 0;
>  
>  put:
> -	np->dev = NULL;
>  	dev_put(ndev);
>  unlock:
>  	rtnl_unlock();
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
