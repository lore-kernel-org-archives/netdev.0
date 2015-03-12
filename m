From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add real socket cookies
Date: Wed, 11 Mar 2015 21:21:12 -0400 (EDT)
Message-ID: <20150311.212112.908171202958424986.davem@davemloft.net>
References: <1426027533.11398.18.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150311.175345.836846566788322568.davem@davemloft.net>
	<1426113035.11398.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, salo@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbbCLBVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 21:21:14 -0400
In-Reply-To: <1426113035.11398.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Mar 2015 15:30:35 -0700

> Note that sk_clone_lock() really does the clear for us :
> 
> net/core/sock.c:1541:		atomic64_set(&newsk->sk_cookie, 0);
> 
> atomic_cmpxchg() is needed here in case a concurrent dumper already
> caught the new socket.

How is newsk visible at this moment?

It is freshly allocated, and not present in any tables.  Nothing even
indirectly links to it at this point.

Visibility only happens after we return from this function, in
routines such as tcp_v4_syn_recv_sock() which do the hash table
insertion.
