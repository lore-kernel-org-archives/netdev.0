From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Limit size of route cache hash table
Date: Mon, 27 Apr 2009 05:40:24 -0700 (PDT)
Message-ID: <20090427.054024.94955211.davem@davemloft.net>
References: <20090426.233638.83897914.davem@davemloft.net>
	<49F5550A.1050805@cosmosbay.com>
	<20090427115007.GC15891@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755996AbZD0Mkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 08:40:31 -0400
In-Reply-To: <20090427115007.GC15891@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Mon, 27 Apr 2009 21:50:07 +1000

> Right now we have no upper limit on the size of the route cache hash table.
> On a 128GB POWER6 box it ends up as 32MB:
> 
>     IP route cache hash table entries: 4194304 (order: 9, 33554432 bytes)
> 
> It would be nice to cap this for memory consumption reasons, but a massive
> hashtable also causes a significant spike when measuring OS jitter.
> 
> With a 32MB hashtable and 4 million entries, rt_worker_func is taking
> 5 ms to complete. On another system with more memory it's taking 14 ms.
> Even though rt_worker_func does call cond_sched() to limit its impact,
> in an HPC environment we want to keep all sources of OS jitter to a minimum.
> 
> With the patch applied we limit the number of entries to 512k which
> can still be overriden by using the rt_entries boot option:
> 
>     IP route cache hash table entries: 524288 (order: 6, 4194304 bytes)
> 
> With this patch rt_worker_func now takes 0.460 ms on the same system.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks!
