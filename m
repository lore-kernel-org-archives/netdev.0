From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: percpu net_device refcount
Date: Mon, 11 Oct 2010 12:49:38 -0700 (PDT)
Message-ID: <20101011.124938.179933637.davem@davemloft.net>
References: <20101011.121344.260085789.davem@davemloft.net>
	<1286825929.3218.7.camel@edumazet-laptop>
	<20101011.124137.102555159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53072
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755925Ab0JKTtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 15:49:16 -0400
In-Reply-To: <20101011.124137.102555159.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 11 Oct 2010 12:41:37 -0700 (PDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 11 Oct 2010 21:38:49 +0200
> 
>> [PATCH net-next] net: percpu net_device refcount
> 
> Excellent, applied, thanks!

Actually I have to revert, this breaks the infiniband drivers
which access netdev->refcnt directly.

drivers/infiniband/hw/nes/nes_verbs.c: In function 'nes_alloc_pd':
drivers/infiniband/hw/nes/nes_verbs.c:786:2: error: 'struct net_device' has no member named 'refcnt'
drivers/infiniband/hw/nes/nes_verbs.c: In function 'nes_create_qp':
drivers/infiniband/hw/nes/nes_verbs.c:1418:2: error: 'struct net_device' has no member named 'refcnt'
drivers/infiniband/hw/nes/nes_cm.c: In function 'nes_disconnect':
drivers/infiniband/hw/nes/nes_cm.c:2703:2: error: 'struct net_device' has no member named 'refcnt'
drivers/infiniband/hw/nes/nes_cm.c: In function 'nes_accept':
drivers/infiniband/hw/nes/nes_cm.c:2793:2: error: 'struct net_device' has no member named 'refcnt'
