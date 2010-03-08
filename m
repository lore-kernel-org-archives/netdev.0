From: David Miller <davem@davemloft.net>
Subject: Re: uninterruptible sleep in unix_dgram_recvmsg
Date: Mon, 08 Mar 2010 12:48:48 -0800 (PST)
Message-ID: <20100308.124848.117951181.davem@davemloft.net>
References: <20100304184114.62881b21@leela>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51364
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755597Ab0CHUs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 15:48:29 -0500
In-Reply-To: <20100304184114.62881b21@leela>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Thu, 4 Mar 2010 18:41:14 +0100

> So instead of that I started to think about why u->readlock is held
> across skb_recv_datagram() anyway. I found that it was added in 2.6.10
> by your patch "[AF_UNIX]: Serialize dgram read using semaphore just
> like stream" which apparently fixed an exploitable race condition
> (CAN-2004-1068).
> 
> I don't know what exactly u->readlock protects here.
> IOW, what race would this patch cause?:

Unfortunately I can't find any discussions about that change
and I can't find my own personal email archives from that far
back.

This is what irks me about handling security issues off-list
and in private.

In any event, I'm pretty sure we need to protect the dequeue
of SKBs from the datagram recv_queue with that mutex.  So
I'm weary to apply your patch.

Can you find a way to fix this without moving the SKB
dequeue outside of the lock?

Thanks.

