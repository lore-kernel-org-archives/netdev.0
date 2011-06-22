From: David Miller <davem@davemloft.net>
Subject: Re: Weird locking in __release_sock()?
Date: Wed, 22 Jun 2011 16:42:14 -0700 (PDT)
Message-ID: <20110622.164214.415427796273622733.davem@davemloft.net>
References: <4E027B41.3040009@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47239 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758222Ab1FVXmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 19:42:16 -0400
In-Reply-To: <4E027B41.3040009@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Wed, 22 Jun 2011 16:31:13 -0700

> In the case of an IPv4 TCP socket, sk_backlog_rcv() calls
> tcp_v4_do_rcv(), which is documented like this:
> 
> /* The socket must have it's spinlock held when we get
>  * here.
> .
> .
> .
> */
> 
> Q: How can this be correct?

sk->lock.owned will be "1" while the backlog is processed.

Exclusive access to the socket is indicated by one of the
following two conditions being true:

1) sk->lock.slock being held
2) sk->lock.owned being non-zero
