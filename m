From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] tun: stop tx queue when limit is hit
Date: Mon, 21 Jul 2014 08:54:20 +0200
Message-ID: <20140721065419.GB21375@breakpoint.cc>
References: <1405882285-3072-1-git-send-email-fw@strlen.de>
 <20140720.223313.1589952322700027038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52565 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751580AbaGUGyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 02:54:21 -0400
Content-Disposition: inline
In-Reply-To: <20140720.223313.1589952322700027038.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Sun, 20 Jul 2014 20:51:25 +0200
> 
> > Currently tun just frees the skb and returns NETDEV_TX_OK
> > when queue length exceeds txqlen.
> > 
> > This causes severe packetloss and unneeded resource
> > consumption on host when sending to vm connected via tun.
> > 
> > Instead, lets stop the transmit queue and start it once
> > packets are consumed from the queue.  This allows the network
> > stack to control applications that send data via tun device.
> 
> I strongly suspect the current behavior is intentional, see
> commit:
> 
> commit 5d097109257c03a71845729f8db6b5770c4bbedc
> Author: Michael S. Tsirkin <mst@redhat.com>
> Date:   Mon Dec 3 10:07:14 2012 +0000
> 
>     tun: only queue packets on device

Looks like you're right :-/

Alright, please ignore my patch.

That being said, the current behaviour isn't ideal either.

It took me quite some time to realize that packetloss
was on the sender side inside tun driver and not on the receiver
vm.  Not stopping the queue was a bit ... unexpected.
