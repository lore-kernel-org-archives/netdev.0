From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 8/8] bridge: Fix netpoll support
Date: Tue, 15 Jun 2010 18:28:17 +0800
Message-ID: <4C1755C1.3060804@redhat.com>
References: <20100611021142.GA24490@gondor.apana.org.au> <E1OMtjm-0006PK-D6@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Matt Mackall <mpm@selenic.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751532Ab0FOKY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 06:24:56 -0400
In-Reply-To: <E1OMtjm-0006PK-D6@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/10 10:12, Herbert Xu wrote:
> bridge: Fix netpoll support
>
> There are multiple problems with the newly added netpoll support:
>
> 1) Use-after-free on each netpoll packet.
> 2) Invoking unsafe code on netpoll/IRQ path.
> 3) Breaks when netpoll is enabled on the underlying device.
>
> This patch fixes all of these problems.  In particular, we now
> allocate proper netpoll structures for each underlying device.
>
> We only allow netpoll to be enabled on the bridge when all the
> devices underneath it support netpoll.  Once it is enabled, we
> do not allow non-netpoll devices to join the bridge (until netpoll
> is disabled again).
>


This is a good idea!

> This allows us to do away with the npinfo juggling that caused
> problem number 1.
>
> Incidentally this patch fixes number 2 by bypassing unsafe code
> such as multicast snooping and netfilter.


Not sure if I understand problem 2) and 3), this patch is not easy
to review. So, what's the point of adding ->np to struct net_bridge_port?
since we already have p->dev->npinfo->netpoll?

Thanks!

