From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 2/2] bridge: netlink dump interface at par
 with brctl
Date: Thu, 26 Jun 2014 17:45:30 -0700 (PDT)
Message-ID: <20140626.174530.4353389845713242.davem@davemloft.net>
References: <1403691683-14290-1-git-send-email-jhs@emojatatu.com>
	<1403691683-14290-3-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	vyasevic@redhat.com, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297AbaF0Apb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 20:45:31 -0400
In-Reply-To: <1403691683-14290-3-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Wed, 25 Jun 2014 06:21:23 -0400

> +				/* 
> +				 * !f->dst is a speacial case for bridge
> +				 * It means the MAC belongs to the bridge
> +				 * Therefore need a little more filtering
> +				 * we only want to dump the !f->dst case
> +				 */

Please format comments:

	/* Like
	 * this.
	 */

in the networking.

> +	for_each_netdev(net, dev) {
> +
> +		if (brport_idx && (dev->ifindex != brport_idx))

Please remove that empty line.

> +			if (cops && cops->ndo_fdb_dump) {
> +				idx = cops->ndo_fdb_dump(skb, cb, br_dev, dev, idx);
> +			}

Single statement basic blocks do not need curly braces.

> +		if (dev->netdev_ops->ndo_fdb_dump) {
> +			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, bdev, dev,
> +							    idx);
>  		}

Likewise.
