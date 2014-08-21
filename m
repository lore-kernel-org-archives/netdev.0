From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 net] packet: handle too big packets for PACKET_V3
Date: Thu, 21 Aug 2014 16:45:11 -0700 (PDT)
Message-ID: <20140821.164511.894966250481146327.davem@davemloft.net>
References: <1408068085.6804.75.camel@edumazet-glaptop2.roam.corp.google.com>
	<0B7AA838-0FC7-4B0C-881E-17FC71748140@alum.mit.edu>
	<1408119364.6804.89.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, dborkman@redhat.com,
	nhorman@tuxdriver.com, brouer@redhat.com, netdev@vger.kernel.org,
	guy@alum.mit.edu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaHUXpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 19:45:13 -0400
In-Reply-To: <1408119364.6804.89.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Aug 2014 09:16:04 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> af_packet can currently overwrite kernel memory by out of bound
> accesses, because it assumed a [new] block can always hold one frame.
> 
> This is not generally the case, even if most existing tools do it right.
> 
> This patch clamps too long frames as API permits, and issue a one time
> error on syslog.
> 
> [  394.357639] tpacket_rcv: packet too big, clamped from 5042 to 3966. macoff=82
> 
> In this example, packet header tp_snaplen was set to 3966,
> and tp_len was set to 5042 (skb->len)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: f6fb8f100b80 ("af-packet: TPACKET_V3 flexible buffer implementation.")

Since both the skb->len and the snaplen are provided to the user in
the ring entry descriptor, it is correct to fix this problem by simply
truncating.

Applied and queued up for -stable, thanks a lot Eric.
