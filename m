From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_unix: speedup /proc/net/unix
Date: Fri, 08 Jun 2012 14:28:03 -0700 (PDT)
Message-ID: <20120608.142803.283545665938074209.davem@davemloft.net>
References: <1339167801.6001.111.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, swhiteho@redhat.com, xemul@parallels.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934516Ab2FHV2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 17:28:04 -0400
In-Reply-To: <1339167801.6001.111.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Jun 2012 17:03:21 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> /proc/net/unix has quadratic behavior, and can hold unix_table_lock for
> a while if high number of unix sockets are alive. (90 ms for 200k
> sockets...)
> 
> We already have a hash table, so its quite easy to use it.
> 
> Problem is unbound sockets are still hashed in a single hash slot
> (unix_socket_table[UNIX_HASH_TABLE])
> 
> This patch also spreads unbound sockets to 256 hash slots, to speedup
> both /proc/net/unix and unix_diag.
> 
> Time to read /proc/net/unix with 200k unix sockets :
> (time dd if=/proc/net/unix of=/dev/null bs=4k)
> 
> before : 520 secs
> after : 2 secs
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Nice work Eric, applied.
