From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/4] bonding: fix multiple 3ad mode sysfs race conditions
Date: Wed, 15 May 2013 17:53:41 +0400
Message-ID: <51939365.4020905@cogentembedded.com>
References: <1368621162-6807-1-git-send-email-nikolay@redhat.com> <1368621162-6807-5-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:52737 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758991Ab3EONxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 09:53:42 -0400
Received: by mail-lb0-f171.google.com with SMTP id v20so1899658lbc.30
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 06:53:40 -0700 (PDT)
In-Reply-To: <1368621162-6807-5-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 15-05-2013 16:32, Nikolay Aleksandrov wrote:

> When bond_3ad_get_active_agg_info() is used in all show_ad_ functions
> it is not protected against slave manipulation and since it walks over
> the slaves and uses them, this can easily result in NULL pointer
> dereference or use of freed memory.

> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
>   drivers/net/bonding/bond_sysfs.c | 21 ++++++++++++++++-----
>   1 file changed, 16 insertions(+), 5 deletions(-)

> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
> index 77ea237..81ef36a 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
[...]
> @@ -1333,7 +1344,7 @@ static ssize_t bonding_show_ad_aggregator(struct device *d,
>   	if (bond->params.mode == BOND_MODE_8023AD) {
>   		struct ad_info ad_info;
>   		count = sprintf(buf, "%d\n",
> -				(bond_3ad_get_active_agg_info(bond, &ad_info))
> +				(get_active_agg_info(bond, &ad_info))
>   				?  0 : ad_info.aggregator_id);
>   	}
>
> @@ -1355,7 +1366,7 @@ static ssize_t bonding_show_ad_num_ports(struct device *d,
>   	if (bond->params.mode == BOND_MODE_8023AD) {
>   		struct ad_info ad_info;
>   		count = sprintf(buf, "%d\n",
> -				(bond_3ad_get_active_agg_info(bond, &ad_info))
> +				(get_active_agg_info(bond, &ad_info))
>   				?  0 : ad_info.ports);
>   	}
>
> @@ -1377,7 +1388,7 @@ static ssize_t bonding_show_ad_actor_key(struct device *d,
>   	if (bond->params.mode == BOND_MODE_8023AD) {
>   		struct ad_info ad_info;
>   		count = sprintf(buf, "%d\n",
> -				(bond_3ad_get_active_agg_info(bond, &ad_info))
> +				(get_active_agg_info(bond, &ad_info))
>   				?  0 : ad_info.actor_key);
>   	}
>
> @@ -1399,7 +1410,7 @@ static ssize_t bonding_show_ad_partner_key(struct device *d,
>   	if (bond->params.mode == BOND_MODE_8023AD) {
>   		struct ad_info ad_info;
>   		count = sprintf(buf, "%d\n",
> -				(bond_3ad_get_active_agg_info(bond, &ad_info))
> +				(get_active_agg_info(bond, &ad_info))
>   				?  0 : ad_info.partner_key);
>   	}

    Perhaps it's time to get rid of the useless parens around function 
call in ?: operator?

WBR, Sergei
