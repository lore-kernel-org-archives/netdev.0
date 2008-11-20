From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] question about inet_listen_lock(), and [PATCH] net:
 listening_hash get a spinlock per bucket
Date: Thu, 20 Nov 2008 00:41:03 -0800 (PST)
Message-ID: <20081120.004103.45482570.davem@davemloft.net>
References: <492199FF.3030205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35870
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753408AbYKTIlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 03:41:03 -0500
In-Reply-To: <492199FF.3030205@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 17 Nov 2008 17:21:19 +0100

> [PATCH] net: listening_hash get a spinlock per bucket
> 
> This patch prepares RCU migration of listening_hash table for
> TCP/DCCP protocols.
> 
> listening_hash table being small (32 slots per protocol), we add
> a spinlock for each slot, instead of a single rwlock for whole table.
> 
> This should reduce hold time of readers, and writers concurrency.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Ok it looks indeed as this sleeping thing was just a queer way to wait
when there was some thread dumping listening sockets.  I guess it must
have been _really_ slow back when that was written by Alexey :)

I've applied your patch to net-next-2.6, thanks Eric!
