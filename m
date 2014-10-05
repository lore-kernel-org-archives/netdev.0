From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: better IFF_XMIT_DST_RELEASE support
Date: Sat, 04 Oct 2014 20:29:00 -0400 (EDT)
Message-ID: <20141004.202900.1107815015981261576.davem@davemloft.net>
References: <1412267647.22242.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaJEA3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:29:03 -0400
In-Reply-To: <1412267647.22242.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Oct 2014 09:34:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Testing xmit_more support with netperf and connected UDP sockets,
> I found strange dst refcount false sharing.
> 
> Current handling of IFF_XMIT_DST_RELEASE is not optimal.
> 
> dropping dst in validate_xmit_skb() is certainly too late in case
> packet was queued by cpu X but dequeued by cpu Y
> 
> The logical point to take care of drop/force is in __dev_queue_xmit()
> before even taking qdisc lock.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I assume you are going to rework this to use a counter indication
in order to deal with the packet scheduler issues Julian brought
up.
