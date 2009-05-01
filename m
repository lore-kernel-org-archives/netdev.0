From: David Miller <davem@davemloft.net>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Fri, 01 May 2009 09:08:15 -0700 (PDT)
Message-ID: <20090501.090815.262436244.davem@davemloft.net>
References: <20090430.070811.260649067.davem@davemloft.net>
	<606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com>
	<49FA932B.4030405@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@whydna.net, jelaas@gmail.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34812
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753765AbZEAQIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 12:08:21 -0400
In-Reply-To: <49FA932B.4030405@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 01 May 2009 08:14:03 +0200

> [PATCH] net: skb_tx_hash() improvements
> 
> When skb_rx_queue_recorded() is true, we dont want to use jash distribution
> as the device driver exactly told us which queue was selected at RX time.
> jhash makes a statistical shuffle, but this wont work with 8 static inputs.
> 
> Later improvements would be to compute reciprocal value of real_num_tx_queues
> to avoid a divide here. But this computation should be done once,
> when real_num_tx_queues is set. This needs a separate patch, and a new
> field in struct net_device.
> 
> Reported-by: Andrew Dickinson <andrew@whydna.net>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, except that I changed the commit message header line to more
reflect that this is in fact a bug fix.

BTW, you don't need the reciprocol when num-tx-queues <= num-rx-queues
(you can just use the RX queue recording as the hash, straight) and
that's the kind of check what I intended to add to net-2.6 had you not
beaten me to this patch.

Also, thanks for giving me absolutely no credit for this whole thing
in your commit message.  I know I do that to you all the time :-/ How
can you forget so quickly that I'm the one that even suggested the
exact code change for Andrew to test in the first place?
