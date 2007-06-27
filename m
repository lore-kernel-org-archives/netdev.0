From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: tx lock deadlock fix
Date: Wed, 27 Jun 2007 00:40:28 -0700 (PDT)
Message-ID: <20070627.004028.101596087.davem@davemloft.net>
References: <20070529173221.5c2dd261@freepuppy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48255
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756292AbXF0HkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 03:40:09 -0400
In-Reply-To: <20070529173221.5c2dd261@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 29 May 2007 17:32:21 -0700

> If sky2 device poll routine is called from netpoll_send_skb, it
> would deadlock. The netpoll_send_skb held the netif_tx_lock, and the
> poll routine could acquire it to clean up skb's. Other drivers
> might use same locking model.
> 
> The driver is correct, netpoll should not introduce more locking problems
> than it causes already. So change the code to drop lock before calling
> poll handler.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux.foundation.org>

Patch applied, thanks Stephen.

Once I get this to Linus would you like me to toss it over
to the -stable folks too?

Thanks.
