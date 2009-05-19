From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_teql: should not dereference skb after
 ndo_start_xmit
Date: Mon, 18 May 2009 19:34:38 -0700 (PDT)
Message-ID: <20090518.193438.158960584.davem@davemloft.net>
References: <4A11391D.8060503@cosmosbay.com>
	<20090518.151256.217066131.davem@davemloft.net>
	<4A120C8B.80108@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jussi.kivilinna@mbnet.fi
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40725
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753112AbZESCek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 22:34:40 -0400
In-Reply-To: <4A120C8B.80108@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 19 May 2009 03:34:03 +0200

> Looking again at teql_master_xmit(), I wonder if there is another
> problem in it.
> 
>     int subq = skb_get_queue_mapping(skb);
> 
> But as a matter of fact, following code assumes subq is 0
> 
> struct netdev_queue *slave_txq = netdev_get_tx_queue(slave, 0);
> ...
> if (__netif_subqueue_stopped(slave, subq) ||
> ...
> 
> Either we should set subq to 0, or call dev_pick_tx() to better
> take into account multi queue slaves ?
> 
> (As teqlN has one queue, I assume original dev_queue_xmit() will
> set skb queue_mapping to 0 before entering teql_master_xmit(), but
> maybe other paths could call teql_master_xmit() not through dev_queue_xmit() ?
> 
> Oh well, time for sleeping a bit...

I was admittedly very hasty with the multiqueue conversion here.
I'll take a closer look at this.
