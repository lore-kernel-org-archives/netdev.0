From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] ipv6 : ip6mr.c : Fix can't match the IPv6
 multicast packets with input net device in netfilter FORWARD chain.
Date: Thu, 02 Aug 2012 23:43:11 -0700 (PDT)
Message-ID: <20120802.234311.2108069975669469931.davem@davemloft.net>
References: <1343975271-4263-1-git-send-email-mypopydev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: mypopydev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843Ab2HCGnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 02:43:15 -0400
In-Reply-To: <1343975271-4263-1-git-send-email-mypopydev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jun Zhao <mypopydev@gmail.com>
Date: Fri,  3 Aug 2012 14:27:51 +0800

> @@ -1960,7 +1962,7 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
>  
>  	IP6CB(skb)->flags |= IP6SKB_FORWARDED;
>  
> -	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, skb->dev, dev,
> +	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, indev, dev,
>  		       ip6mr_forward2_finish);
>  

This patch has the same problem I mentioned, it means someone who is
now matching on the VIF device will now fail to do son.

You have to understand that you simply cannot change the behavior
here without breaking something for someone.
