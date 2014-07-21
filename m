From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] tun: stop tx queue when limit is hit
Date: Sun, 20 Jul 2014 22:33:13 -0700 (PDT)
Message-ID: <20140720.223313.1589952322700027038.davem@davemloft.net>
References: <1405882285-3072-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbaGUFdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 01:33:14 -0400
In-Reply-To: <1405882285-3072-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 20 Jul 2014 20:51:25 +0200

> Currently tun just frees the skb and returns NETDEV_TX_OK
> when queue length exceeds txqlen.
> 
> This causes severe packetloss and unneeded resource
> consumption on host when sending to vm connected via tun.
> 
> Instead, lets stop the transmit queue and start it once
> packets are consumed from the queue.  This allows the network
> stack to control applications that send data via tun device.

I strongly suspect the current behavior is intentional, see
commit:

commit 5d097109257c03a71845729f8db6b5770c4bbedc
Author: Michael S. Tsirkin <mst@redhat.com>
Date:   Mon Dec 3 10:07:14 2012 +0000

    tun: only queue packets on device

for example.
