From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] enic: fix rx skb checksum
Date: Thu, 18 Dec 2014 12:49:10 -0500 (EST)
Message-ID: <20141218.124910.2223321203114038063.davem@davemloft.net>
References: <1418898522-13588-1-git-send-email-_govind@gmx.com>
	<1418920017.9773.80.camel@edumazet-glaptop2.roam.corp.google.com>
	<17951.1418924367@famine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, _govind@gmx.com, netdev@vger.kernel.org,
	ssujith@cisco.com, benve@cisco.com, jbenc@redhat.com,
	sassmann@redhat.com
To: jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbaLRRtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 12:49:13 -0500
In-Reply-To: <17951.1418924367@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <jay.vosburgh@canonical.com>
Date: Thu, 18 Dec 2014 09:39:27 -0800

> @@ -1694,6 +1694,7 @@ int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
>  
>  	skb_scrub_packet(skb, true);
>  	skb->protocol = eth_type_trans(skb, dev);
> +	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
>  
>  	return 0;
>  }
> 
> 	I'd very much appreciate comments from someone who knows the
> checksum logic better than I do as to whether this is a reasonable thing
> to do.

This looks quite reasonable to me.
