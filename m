From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: dont set inet_rcv_saddr in connect()
Date: Tue, 07 Sep 2010 22:51:46 -0700 (PDT)
Message-ID: <20100907.225146.232739797.davem@davemloft.net>
References: <4C86F653.6070707@hp.com>
	<20100907.203410.245386536.davem@davemloft.net>
	<1283920965.2634.723.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, ole@ans.pl, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46572
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751228Ab0IHFv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 01:51:28 -0400
In-Reply-To: <1283920965.2634.723.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Sep 2010 06:42:45 +0200

> Problem is AF_UNSPEC always clears the remote address (as stated in
> manual), and sometimes local one (as not stated)
> 
> if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
> 	inet_reset_saddr(sk);
> 
> This is the workaround that was coded years ago in Linux to undo the
> local addr setting ;)

Ok, I mis-remembered about AF_UNSPEC, I thought BSD did it too, it
does not.

But we really offer the most flexibility here because we offer this.

In BSD case, connect() on an already connect()'d UDP socket
unconditionally zaps the local address setting (because, as Stevens
states, that local address "might" have been created by a previous
connect()).

This forces the application to re-bind() the local address if it wants
to use something other than what connect() is going to choose.

We leave the local settings alone for normal connect() on already
connect()'d sockets, and provide connect(AF_UNSPEC) to explicitly kill
connect() created local and remote associations.

This allows bind() settings to survive through multiple connect()
calls if the user wants, a facility BSD does not provide.
