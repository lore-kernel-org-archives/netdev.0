From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] ethtool: check the ethtool_ops is NULL in dev_ethtool
Date: Mon, 17 Feb 2014 18:09:58 +0100
Message-ID: <53024266.8010700@redhat.com>
References: <5301F32C.4040704@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23433 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752056AbaBQRKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 12:10:12 -0500
In-Reply-To: <5301F32C.4040704@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2014 12:31 PM, Wang Weidong wrote:
> some drivers maybe not implement the ethtool_ops with only
> set NULL. So when call the ethtool cmds will lead to a
> 'NULL pointer dereference'.
>
> So add a checking in dev_ethtool.
>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>   net/core/ethtool.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 30071de..f418dcb 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1499,6 +1499,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
>   		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
>   			return -EPERM;
>   	}
> +	

You have a trailing whitespace/tab in the line above. Please
use checkpatch for detecting such things.

Can you be more specific with "some drivers"? Any driver that
is in the mainline tree?

> +	if (!dev->ethtool_ops)
> +		return -EOPNOTSUPP;
>
>   	if (dev->ethtool_ops->begin) {
>   		rc = dev->ethtool_ops->begin(dev);
>
