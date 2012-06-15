From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix panic when TX ring is full
Date: Fri, 15 Jun 2012 15:30:49 -0700 (PDT)
Message-ID: <20120615.153049.103988387813257203.davem@davemloft.net>
References: <1339616716.22704.661.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, evansr@google.com,
	eilong@broadcom.com, meravs@broadcom.com, yanivr@broadcom.com,
	willemb@google.com, thruby@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758316Ab2FOWau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 18:30:50 -0400
In-Reply-To: <1339616716.22704.661.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Jun 2012 21:45:16 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> There is a off by one error in the minimal number of BD in
> bnx2x_start_xmit() and bnx2x_tx_int() before stopping/resuming tx queue.
> 
> A full size GSO packet, with data included in skb->head really needs
> (MAX_SKB_FRAGS + 4) BDs, because of bnx2x_tx_split()
> 
> This error triggers if BQL is disabled and heavy TCP transmit traffic
> occurs.
> 
> bnx2x_tx_split() definitely can be called, remove a wrong comment.
> 
> Reported-by: Tomas Hruby <thruby@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I got tired of waiting for the Broadcom "maintainers" to review this,
so I just applied it to 'net', thanks Eric.
