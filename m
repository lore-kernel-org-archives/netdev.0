From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: [PATCH net-next 01/12] net/mlx4_en: Reuse mapped memory in RX
 flow
Date: Tue, 10 Dec 2013 11:47:05 +0200
Message-ID: <52A6E319.20407@gmail.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com>		 <1386506152-10298-2-git-send-email-amirv@mellanox.com>	 <1386530458.30495.286.camel@edumazet-glaptop2.roam.corp.google.com>	 <52A590F0.7000508@mellanox.com> <1386602236.30495.328.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:49375 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743Ab3LJJrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 04:47:11 -0500
Received: by mail-ea0-f181.google.com with SMTP id m10so2113521eaj.40
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 01:47:10 -0800 (PST)
In-Reply-To: <1386602236.30495.328.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2013 17:17, Eric Dumazet wrote:
> On Mon, 2013-12-09 at 11:44 +0200, Amir Vadai wrote:
> 
>> We get optimal performance when rx rings are mapped 1:1 to cpu's - IRQ
>> affinity is set to this CPU, and memory is allocated on the NUMA node
>> close to it (ring->numa_node)
>> In order to do that, we will post a patch soon to use
>> irq_set_affinity_hint() in order to hint the irq balancer. Till this
>> patch is applied, users should set irq affinity through sysfs and
>> disable the irq balancer.
> 
> Point is : You have nothing to do to affine memory allocations.
> 
> The big problem is correct IRQ affinity, which as you said is addressed
> in a different way/patch
> 
> If the IRQ is properly setup, automatically or by irq affinities,
> then memory will be allocated on the right node, its properly done
> by all memory allocators.
> 
> The xxx_alloc_node() variants in the fast path are therefore not needed,
> and not using them avoids catastrophic results if affinities are not
> properly set.
You are right. Will be fixed in V1 too.
We'll use xxx_alloc_node() on the initialization phase, but on the fast
path let the kernel choose the NUMA node.

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
