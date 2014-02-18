From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH v2] ethtool: check the ethtool_ops is NULL in dev_ethtool
Date: Tue, 18 Feb 2014 18:41:24 +0800
Message-ID: <530338D4.80801@huawei.com>
References: <5301F32C.4040704@huawei.com> <5302BAA0.9060905@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Daniel Borkmann <dborkman@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:28848 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700AbaBRKlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 05:41:32 -0500
In-Reply-To: <5302BAA0.9060905@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just ignore it.

Regards
Wang

On 2014/2/18 9:42, Wang Weidong wrote:
> some drivers maybe not implement the ethtool_ops with only
> set NULL to ethtool_ops. So when call the ethtool devx will
> lead to a 'NULL pointer dereference'.
> 
> So add a check in dev_ethtool
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
> Change note:
> 
> v2: fix a trailing whitespace/tab pointed out by Daniel
> 
> ---
>  net/core/ethtool.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 30071de..c8cfd8f 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1500,6 +1500,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
>  			return -EPERM;
>  	}
>  
> +	if (!dev->ethtool_ops)
> +		return -EOPNOTSUPP;
> +
>  	if (dev->ethtool_ops->begin) {
>  		rc = dev->ethtool_ops->begin(dev);
>  		if (rc  < 0)
> 
