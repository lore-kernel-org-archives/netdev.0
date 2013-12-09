From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 01/12] net/mlx4_en: Reuse mapped memory in RX
 flow
Date: Mon, 09 Dec 2013 07:17:16 -0800
Message-ID: <1386602236.30495.328.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
		 <1386506152-10298-2-git-send-email-amirv@mellanox.com>
	 <1386530458.30495.286.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52A590F0.7000508@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:33569 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933799Ab3LIPRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 10:17:17 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so5382918pdj.26
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 07:17:17 -0800 (PST)
In-Reply-To: <52A590F0.7000508@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-09 at 11:44 +0200, Amir Vadai wrote:

> We get optimal performance when rx rings are mapped 1:1 to cpu's - IRQ
> affinity is set to this CPU, and memory is allocated on the NUMA node
> close to it (ring->numa_node)
> In order to do that, we will post a patch soon to use
> irq_set_affinity_hint() in order to hint the irq balancer. Till this
> patch is applied, users should set irq affinity through sysfs and
> disable the irq balancer.

Point is : You have nothing to do to affine memory allocations.

The big problem is correct IRQ affinity, which as you said is addressed
in a different way/patch

If the IRQ is properly setup, automatically or by irq affinities,
then memory will be allocated on the right node, its properly done
by all memory allocators.

The xxx_alloc_node() variants in the fast path are therefore not needed,
and not using them avoids catastrophic results if affinities are not
properly set.
