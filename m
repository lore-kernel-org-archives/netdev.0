From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v3 13/13] bonding: pr_debug instead of pr_warn
 in bond_arp_send_all
Date: Wed, 28 Aug 2013 09:15:48 -0700
Message-ID: <1377706548.1928.16.camel@joe-AO722>
References: <1377705842-8276-1-git-send-email-vfalico@redhat.com>
	 <1377705842-8276-14-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>,
	Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46867 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753328Ab3H1QPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 12:15:48 -0400
In-Reply-To: <1377705842-8276-14-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(adding Jason Baron to comment on dynamic_debug)

On Wed, 2013-08-28 at 18:04 +0200, Veaceslav Falico wrote:
> They're simply annoying and will spam dmesg constantly if we hit them, so
> convert to pr_debug so that we still can access them in case of debugging.
> 
> v2: new patch
> v3: no change

Hi Veaceslav:

This changelog bit maybe is better placed below the ---

Hey Jason:

This conversion loses the net_ratelimit().

This maybe is an example of where dynamic_debug
could be better with some global rate control.

> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c |   14 ++++++--------
>  1 files changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index a52cff1..47e1052 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2336,10 +2336,8 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
>  		rt = ip_route_output(dev_net(bond->dev), targets[i], 0,
>  				     RTO_ONLINK, 0);
>  		if (IS_ERR(rt)) {
> -			if (net_ratelimit()) {
> -				pr_warning("%s: no route to arp_ip_target %pI4\n",
> -					   bond->dev->name, &targets[i]);
> -			}
> +			pr_debug("%s: no route to arp_ip_target %pI4\n",
> +				 bond->dev->name, &targets[i]);
>  			continue;
>  		}
>  
> @@ -2364,10 +2362,10 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
>  		rcu_read_unlock();
>  
>  		/* Not our device - skip */
> -		if (net_ratelimit())
> -			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
> -				   bond->dev->name, &targets[i],
> -				   rt->dst.dev ? rt->dst.dev->name : "NULL");
> +		pr_debug("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
> +			 bond->dev->name, &targets[i],
> +			 rt->dst.dev ? rt->dst.dev->name : "NULL");
> +
>  		ip_rt_put(rt);
>  		continue;
>  
