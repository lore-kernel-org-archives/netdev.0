From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Fri, 12 Apr 2013 15:19:16 -0400 (EDT)
Message-ID: <20130412.151916.63924835658790088.davem@davemloft.net>
References: <516641CF.4020101@us.ibm.com>
	<1937058599.2214531.1365659704193.JavaMail.root@redhat.com>
	<1365724799.3563.5.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab3DLTTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 15:19:18 -0400
In-Reply-To: <1365724799.3563.5.camel@sridhar.usor.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 11 Apr 2013 16:59:59 -0700

> @@ -1013,7 +1013,7 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  	}
>  
>  	/* Bypass encapsulation if the destination is local */
> -	if (rt->rt_flags & RTCF_LOCAL) {
> +	if (rt->dst.dev->flags & IFF_LOOPBACK) {
>  		struct vxlan_dev *dst_vxlan;

This looks terrible, and ad-hoc.  You need to find a cleaner
way to express exactly what you're trying to do otherwise I'm
reverting your change.
