From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next] net: remove useless if check from register_netdevice()
Date: Wed, 12 Feb 2014 16:24:31 +0800
Message-ID: <52FB2FBF.7050907@huawei.com>
References: <1392191152-24182-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Denis Kirjanov <kda@linux-powerpc.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:7039 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaBLIZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 03:25:01 -0500
In-Reply-To: <1392191152-24182-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/12 15:45, Denis Kirjanov wrote:
> remove useless if check from register_netdevice()
> 
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> ---
>  net/core/dev.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4ad1b78..4be9a37 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5876,8 +5876,7 @@ int register_netdevice(struct net_device *dev)
>  	if (dev->netdev_ops->ndo_init) {
>  		ret = dev->netdev_ops->ndo_init(dev);
>  		if (ret) {
> -			if (ret > 0)
> -				ret = -EIO;
> +            ret = -EIO;

and:
some ndo_init() will return -ENOMEM, not only -EIO


>  			goto out;
>  		}
>  	}
> 
