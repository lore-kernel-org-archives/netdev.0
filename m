From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch net-next v7 5/6] vxlan: respect disable_ipv6 sysctl
Date: Tue, 30 Apr 2013 16:27:41 +0400
Message-ID: <517FB8BD.3090708@cogentembedded.com>
References: <1367311395-15891-1-git-send-email-amwang@redhat.com> <1367311395-15891-6-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:43740 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760027Ab3D3M2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 08:28:06 -0400
Received: by mail-la0-f52.google.com with SMTP id fd20so369678lab.11
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 05:28:04 -0700 (PDT)
In-Reply-To: <1367311395-15891-6-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 30-04-2013 12:43, Cong Wang wrote:

> From: Cong Wang <amwang@redhat.com>

> When disable_ipv6 is set, we should not allow IPv6 vxlan
> device to be created on top of it.

> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>   drivers/net/vxlan.c |   12 ++++++++++++
>   1 files changed, 12 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index bb39e67..ec1007a 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
[...]
> @@ -1722,6 +1725,15 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
>   			return -ENODEV;
>   		}
>
> +#if IS_ENABLED(CONFIG_IPV6)
> +		if (use_ipv6) {
> +			struct inet6_dev *idev = in6_dev_get(lowerdev);

    Empty line wouldn't hurt here, after declaration.

> +			if (idev && idev->cnf.disable_ipv6)
> +					return -EPERM;
> +		}
> +#else
> +		BUG_ON(use_ipv6);
> +#endif

WBR, Sergei
