From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: tx scalability works :
 tx_packets/tx_bytes/tx_dropped
Date: Mon, 18 May 2009 15:15:22 -0700 (PDT)
Message-ID: <20090518.151522.70235359.davem@davemloft.net>
References: <4A11396D.50108@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41541
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753583AbZERWPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 18:15:24 -0400
In-Reply-To: <4A11396D.50108@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 18 May 2009 12:33:17 +0200

> offsetof(struct net_device, features)=0x44
> offsetof(struct net_device, stats.tx_packets)=0x54
> offsetof(struct net_device, stats.tx_bytes)=0x5c
> offsetof(struct net_device, stats.tx_dropped)=0x6c
> 
> This means drivers that touch stats.tx_packets/stats.tx_bytes in their
> tx path can slow down SMP operations, since they dirty a cache line
> that should stay shared (dev->features is needed in rx and tx paths)
> 
> We could move away stats field in net_device but it wont help that much.
> (Two cache lines dirtied in tx path, we can do one only)
> 
> Better solution is to add tx_packets/tx_bytes/tx_dropped in struct netdev_queue
> because this structure is already touched in tx path and counters
> updates will then be free.
> 
> First patch adds the infrastructure, and second one uses this
> infrastructure for VLAN devices, for which I spoted the performance
> problem on Gigabit links.
> 
> rx path has same problem of course, but less prevalent as less
> cpus are involved in rx path if IRQ affinities not too dumb.

Looks great, both patches applied, thanks!
