From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 14:29:06 +0300
Message-ID: <20090107112906.GA28161@ioremap.net>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net> <20090106183704.GC32491@kernel.dk> <20090107044232.GA22218@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, Willy Tarreau <w@1wt.eu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:38218 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752383AbZAGL3J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 06:29:09 -0500
Content-Disposition: inline
In-Reply-To: <20090107044232.GA22218@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert.

On Wed, Jan 07, 2009 at 03:42:32PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> I see the problem.
> 
> The socket pipes in net/core/skbuff.c use references on the skb
> to hold down the memory in skb->head as well as the pages in the
> skb.
> 
> Unfortunately, once the pipe is fed into sendpage we only use
> page reference counting to pin down the memory.  So as soon as
> sendpage returns we drop the ref count on the skb, thus freeing
> the memory in skb->head, which is yet to be transmitted.
> 
> Moral: Using page reference counts on skb->head is wrong.

That would not happen without scatter-gather support on the interface,
date would be plain copied, and after Jarek's requst Willy confirmed
that corruption happens with all acceleration being turned off.

-- 
	Evgeniy Polyakov
