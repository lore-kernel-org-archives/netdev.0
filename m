From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 net-next 02/27] net: add RCU variant to search for
 netdev_adjacent link
Date: Tue, 17 Sep 2013 02:23:18 +0100
Message-ID: <1379380998.23881.20.camel@deadeye.wl.decadent.org.uk>
References: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
	 <1379378812-18346-3-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57889 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880Ab3IQBX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:23:27 -0400
In-Reply-To: <1379378812-18346-3-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-17 at 02:46 +0200, Veaceslav Falico wrote:
> Currently we have only the RTNL flavour, however we can traverse it while
> holding only RCU, so add the RCU search. Add only one function that will be
> used further, other functions can be added easily afterwards, if anyone
> would need them.
[...]
> +static struct netdev_adjacent *__netdev_find_adj_rcu(struct net_device *dev,
> +						     struct net_device *adj_dev,
> +						     bool upper, bool neighbour)
> +{
> +	struct netdev_adjacent *adj;
> +	struct list_head *adj_list;
> +
> +	if (neighbour)
> +		adj_list = upper ? &dev->adj_list.upper :
> +				   &dev->adj_list.lower;
> +	else
> +		adj_list = upper ? &dev->all_adj_list.upper :
> +				   &dev->all_adj_list.lower;

I think it would be clearer to make adj_list a parameter, rather than
taking the dev and a pair of booleans.

Ben.

> +	list_for_each_entry_rcu(adj, adj_list, list) {
> +		if (adj->dev == adj_dev)
> +			return adj;
> +	}
> +	return NULL;
> +}
> +
> +static struct netdev_adjacent *__netdev_lower_find_rcu(struct net_device *dev,
> +							struct net_device *ldev)
> +{
> +	return __netdev_find_adj_rcu(dev, ldev, false, true);
> +}
> +
>  static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
>  						 struct net_device *adj_dev,
>  						 bool upper, bool neighbour)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
