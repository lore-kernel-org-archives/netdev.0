From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix problem in reading sock TX queue
Date: Wed, 14 Jul 2010 20:50:41 -0700 (PDT)
Message-ID: <20100714.205041.246520770.davem@davemloft.net>
References: <alpine.DEB.1.00.1007142025430.22782@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47813
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932260Ab0GODu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 23:50:26 -0400
In-Reply-To: <alpine.DEB.1.00.1007142025430.22782@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 14 Jul 2010 20:48:08 -0700 (PDT)

> Fix problem in reading the tx_queue recorded in a socket.  In
> dev_pick_tx, the TX queue is read by doing a check with
> sk_tx_queue_recorded on the socket, followed by a sk_tx_queue_get.
> The problem is that there is not mutual exclusion across these
> calls in the socket so it it is possible that the queue in the
> sock can be invalidated after sk_tx_queue_recorded is called so
> that sk_tx_queue get returns -1, which sets 65535 in queue_index
> and thus dev_pick_tx returns 65536 which is a bogus queue and
> can cause crash in dev_queue_xmit.
> 
> We fix this by only calling sk_tx_queue_get which does the proper
> checks.  The interface is that sk_tx_queue_get returns the TX queue
> if the sock argument is non-NULL and TX queue is recorded, else it
> returns -1.  sk_tx_queue_recorded is no longer used so it can be
> completely removed.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom!
