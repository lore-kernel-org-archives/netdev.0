From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Fix corrupted queue_mapping
Date: Thu, 07 Jun 2012 22:46:04 -0700 (PDT)
Message-ID: <20120607.224604.1263677055122853939.davem@davemloft.net>
References: <alpine.DEB.2.00.1206072201200.13686@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933363Ab2FHFqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 01:46:07 -0400
In-Reply-To: <alpine.DEB.2.00.1206072201200.13686@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 7 Jun 2012 22:05:42 -0700 (PDT)

> @@ -381,7 +382,8 @@ struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr)
>  	return next;
>  }
>  
> -#define bond_queue_mapping(skb) (*(u16 *)((skb)->cb))
> +#define bond_queue_mapping(skb) (*(u16 *)((skb)->cb + \
> +    sizeof(struct qdisc_skb_cb)))
>  
>  /**
>   * bond_dev_queue_xmit - Prepare skb for xmit.

I know it's a little bit more work, but please declare a proper
datastructure which shows explicitly what's going on, like Infiniband
does in drivers/infiniband/ulp/ipoib/ipoib.h

struct bond_skb_cb {
	struct qdisc_skb_cb	qdisc_cb;
	u16			queue_mapping;
};

Actually, this probably means there is also a conflict and thus
queue mapping corruption possible for bonded infiniband. :-/
