From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: tcp_make_synack() should clear skb->tstamp
Date: Thu, 09 Apr 2015 17:29:32 -0400 (EDT)
Message-ID: <20150409.172932.729604382252399749.davem@davemloft.net>
References: <1428611516.25985.275.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818AbbDIV3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 17:29:33 -0400
In-Reply-To: <1428611516.25985.275.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Apr 2015 13:31:56 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I noticed tcpdump was giving funky timestamps for locally
> generated SYNACK messages on loopback interface.
> 
> 11:42:46.938990 IP 127.0.0.1.48245 > 127.0.0.2.23850: S
> 945476042:945476042(0) win 43690 <mss 65495,nop,nop,sackOK,nop,wscale 7>
> 
> 20:28:58.502209 IP 127.0.0.2.23850 > 127.0.0.1.48245: S
> 3160535375:3160535375(0) ack 945476043 win 43690 <mss
> 65495,nop,nop,sackOK,nop,wscale 7>
> 
> This is because we need to clear skb->tstamp before
> entering lower stack, otherwise net_timestamp_check()
> does not set skb->tstamp.
> 
> Fixes: 7faee5c0d514 ("tcp: remove TCP_SKB_CB(skb)->when")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
