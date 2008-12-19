From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] net: Fix oops in dev_ifsioc()
Date: Fri, 19 Dec 2008 16:02:51 +0800
Message-ID: <494B552B.1010602@cn.fujitsu.com>
References: <20081219070431.GA7189@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54386 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752731AbYLSIDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 03:03:04 -0500
In-Reply-To: <20081219070431.GA7189@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski said the following on 2008-12-19 15:04:
> A command like this: "brctl addif br1 eth1" issued as a user gave me
> an oops when bridge module wasn't loaded. It's caused by using a dev
> pointer before checking for NULL.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
> 
>  net/core/dev.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 048cf11..daca72e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3745,11 +3745,13 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
>  {
>  	int err;
>  	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
> -	const struct net_device_ops *ops = dev->netdev_ops;
> +	const struct net_device_ops *ops;
>  
>  	if (!dev)
>  		return -ENODEV;
>  
> +	ops = dev->netdev_ops;
> +
>  	switch (cmd) {
>  		case SIOCSIFFLAGS:	/* Set interface flags */
>  			return dev_change_flags(dev, ifr->ifr_flags);

Subject will be changed, sorry.
Seems Julia  is doing "Move a dereference below a NULL test" check,
but why the coccinelle missed this one?

