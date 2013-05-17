From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch net-next v8 07/11] vxlan: respect disable_ipv6 sysctl
Date: Fri, 17 May 2013 17:07:06 +0400
Message-ID: <51962B7A.9090703@cogentembedded.com>
References: <1368750099-14086-1-git-send-email-amwang@redhat.com> <1368750099-14086-8-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:50973 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755890Ab3EQNHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 09:07:03 -0400
Received: by mail-lb0-f173.google.com with SMTP id t10so4374527lbi.32
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 06:07:01 -0700 (PDT)
In-Reply-To: <1368750099-14086-8-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-2013 4:21, Cong Wang wrote:

> From: Cong Wang <amwang@redhat.com>

> When disable_ipv6 is set, we should not allow IPv6 vxlan
> device created on top of it.

> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>   drivers/net/vxlan.c |   14 ++++++++++++++
>   1 files changed, 14 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 46c59a6..1ee79e0 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
[...]
> @@ -1734,6 +1737,17 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
>   			return -ENODEV;
>   		}
>
> +#if IS_ENABLED(CONFIG_IPV6)

    Why not:

	if (IS_ENABLED(CONFIG_IPV6))

    #if's in the function body are frowned upon.


> +		if (use_ipv6) {
> +			struct inet6_dev *idev = in6_dev_get(lowerdev);

    Empty line wouldn't hurt here, after declaration...

> +			if (idev && idev->cnf.disable_ipv6) {
> +				pr_info("IPv6 is disabled via sysctl\n");
> +				return -EPERM;
> +			}
> +		}
> +#else
> +		BUG_ON(use_ipv6);
> +#endif

WBR, Sergei
