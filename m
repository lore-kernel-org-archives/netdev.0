From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] gso: handle new frag_list of frags GRO packets
Date: Thu, 21 Nov 2013 14:12:50 -0500 (EST)
Message-ID: <20131121.141250.1850041110555494669.davem@davemloft.net>
References: <1385058216.10637.53.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131121.133824.1318844228024646798.davem@davemloft.net>
	<1385061004.10637.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux@eikelenboom.it,
	edumazet@google.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373Ab3KUTMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 14:12:54 -0500
In-Reply-To: <1385061004.10637.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Nov 2013 11:10:04 -0800

> From: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Recently GRO started generating packets with frag_lists of frags.
> This was not handled by GSO, thus leading to a crash.
> 
> Thankfully these packets are of a regular form and are easy to
> handle.  This patch handles them in two ways.  For completely
> non-linear frag_list entries, we simply continue to iterate over
> the frag_list frags once we exhaust the normal frags.  For frag_list
> entries with linear parts, we call pskb_trim on the first part
> of the frag_list skb, and then process the rest of the frags in
> the usual way.
> 
> This patch also kills a chunk of dead frag_list code that has
> obviously never ever been run since it ends up generating a bogus
> GSO-segmented packet with a frag_list entry.
> 
> Future work is planned to split super big packets into TSO
> ones.
> 
> Fixes: 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> Reported-by: Jerry Chu <hkchu@google.com>
> Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Sander Eikelenboom <linux@eikelenboom.it>
> Tested-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for 3.12-stable, thanks!
