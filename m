From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] net: remove skb_orphan_try()
Date: Fri, 15 Jun 2012 09:15:59 +0200
Message-ID: <4FDAE12F.5000804@hartkopp.net>
References: <1339667417.22704.707.camel@edumazet-glaptop>  <20120614.030021.2291563831943273331.davem@davemloft.net>  <1339668471.22704.714.camel@edumazet-glaptop>  <20120614.033153.258221733380821664.davem@davemloft.net> <1339692164.7491.64.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jhautbois@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:36989 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab2FOHQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 03:16:04 -0400
In-Reply-To: <1339692164.7491.64.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.06.2012 18:42, Eric Dumazet wrote:


> 
> [PATCH] net: remove skb_orphan_try()
> 
> Orphaning skb in dev_hard_start_xmit() makes bonding behavior
> unfriendly for applications sending big UDP bursts : Once packets
> pass the bonding device and come to real device, they might hit a full
> qdisc and be dropped. Without orphaning, the sender is automatically
> throttled because sk->sk_wmemalloc reaches sk->sk_sndbuf (assuming
> sk_sndbuf is not too big)
> 
> We could try to defer the orphaning adding another test in
> dev_hard_start_xmit(), but all this seems of little gain,
> now that BQL tends to make packets more likely to be parked
> in Qdisc queues instead of NIC TX ring, in cases where performance
> matters.
> 
> Reverts commits :
> fc6055a5ba31 net: Introduce skb_orphan_try()
> 87fd308cfc6b net: skb_tx_hash() fix relative to skb_orphan_try()
> and removes SKBTX_DRV_NEEDS_SK_REF flag
> 
> Reported-and-bisected-by: Jean-Michel Hautbois <jhautbois@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/linux/skbuff.h |    7 ++-----
>  net/can/raw.c          |    3 ---
>  net/core/dev.c         |   23 +----------------------
>  net/iucv/af_iucv.c     |    1 -
>  4 files changed, 3 insertions(+), 31 deletions(-)
> 


As i originally introduced the SKBTX_DRV_NEEDS_SK_REF flag to preserve the skb
packet flow for CAN i'm pretty happy to see that skb_orphan_try() goes away
again :-)

I also tested this patch with my test-apps that would detect these problems.

Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Tnx Eric!

Regards,
Oliver
