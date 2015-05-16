From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH] rhashtable: Add cap on number of elements in hash
 table
Date: Sat, 16 May 2015 18:08:43 -0400 (EDT)
Message-ID: <20150516.180843.2228294721060919804.davem@davemloft.net>
References: <20150424005729.GA27075@gondor.apana.org.au>
	<20150513080640.GA27800@gondor.apana.org.au>
	<20150515033047.GA15288@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org, kaber@trash.net,
	tgraf@suug.ch, johannes.berg@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38229 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbbEPWIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 18:08:45 -0400
In-Reply-To: <20150515033047.GA15288@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 15 May 2015 11:30:47 +0800

> We currently have no limit on the number of elements in a hash table.
> This is a problem because some users (tipc) set a ceiling on the
> maximum table size and when that is reached the hash table may
> degenerate.  Others may encounter OOM when growing and if we allow
> insertions when that happens the hash table perofrmance may also
> suffer.
> 
> This patch adds a new paramater insecure_max_entries which becomes
> the cap on the table.  If unset it defaults to max_size * 2.  If
> it is also zero it means that there is no cap on the number of
> elements in the table.  However, the table will grow whenever the
> utilisation hits 100% and if that growth fails, you will get ENOMEM
> on insertion.
> 
> As allowing oversubscription is potentially dangerous, the name
> contains the word insecure.
> 
> Note that the cap is not a hard limit.  This is done for performance
> reasons as enforcing a hard limit will result in use of atomic ops
> that are heavier than the ones we currently use.
> 
> The reasoning is that we're only guarding against a gross over-
> subscription of the table, rather than a small breach of the limit.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
