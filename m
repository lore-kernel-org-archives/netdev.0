From: David Miller <davem@davemloft.net>
Subject: Re: question about __udp6_lib_err usage of __udp6_lib_lookup
Date: Wed, 04 Sep 2013 23:21:20 -0400 (EDT)
Message-ID: <20130904.232120.2047234060467188366.davem@davemloft.net>
References: <20130905024434.GA8219@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905Ab3IEDVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 23:21:21 -0400
In-Reply-To: <20130905024434.GA8219@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Wed, 4 Sep 2013 22:44:34 -0400

> __udp6_lib_lookup's prototype is ...
> 
> struct sock *__udp6_lib_lookup(struct net *net,
>                                       const struct in6_addr *saddr, __be16 sport,
>                                       const struct in6_addr *daddr, __be16 dport,
>                                       int dif, struct udp_table *udptable)
> 
> But the usage in __udp6_lib_err is...
> 
>  521         sk = __udp6_lib_lookup(dev_net(skb->dev), daddr, uh->dest,
>  522                                saddr, uh->source, inet6_iif(skb), udptable);
> 
> With the source/dest addr/port arguments swapped. Is this intentional ?

Yes, because we are looking at the headers of a packet we transmitted,
quoted in an ICMP response.
