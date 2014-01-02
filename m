From: David Miller <davem@davemloft.net>
Subject: Re: IrDA woes..
Date: Thu, 02 Jan 2014 03:46:53 -0500 (EST)
Message-ID: <20140102.034653.1968429090467668489.davem@davemloft.net>
References: <CA+55aFz2CQ4B1JSpQ75TuQrrd9sUnhV+u=T2dWZY2NTTT5OmpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaABIqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 03:46:55 -0500
In-Reply-To: <CA+55aFz2CQ4B1JSpQ75TuQrrd9sUnhV+u=T2dWZY2NTTT5OmpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 31 Dec 2013 12:08:43 -0800

> One of the oopses seems simple: irda_attach() will do

I assume you mean irda_connect().

>         if (sk->sk_prot->disconnect(sk, flags))
>                 sock->state = SS_DISCONNECTING;
> 
> if the connection fails. But sk_prot->disconnect is NULL for IrDA, so
> that will just oops. Apparently real devices don't end up ever
> triggering that, but I don't think it can ever have worked.

That sk_prot should be irda_proto, which doesn't provide any non-NULL
operations ?!?!

That snippet was probably cut and pasted from another protocol's
create implementation.

Generic code (such as that in net/core/sock.c) checks if the
various sk_prot methods are NULL before trying to invoke them.

I think the thing to do for now is to simply remove those two lines.

I don't believe that anyone has looked closely at this code for
a long time except with automated tools like semantic checkers.
