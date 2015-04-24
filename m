From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Fri, 24 Apr 2015 09:06:08 +0100
Message-ID: <20150424080608.GM21799@casper.infradead.org>
References: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
 <20150423.115919.1353583175267783165.davem@davemloft.net>
 <20150424005729.GA27075@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	netdev@vger.kernel.org, kaber@trash.net, johannes.berg@intel.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44112 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755640AbbDXIGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 04:06:13 -0400
Content-Disposition: inline
In-Reply-To: <20150424005729.GA27075@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/15 at 08:57am, Herbert Xu wrote:
> It seems that I lost track somewhere along the line.  I meant
> to add an explicit limit on the overall number of entries since
> that was what users like netlink expected but never got around
> to doing it.  Instead it seems that we're currently relying on
> the rht_grow_above_100 to protect us.

Can we please just take Johannes's fix as-is first? It fixes
the bug at hand in an isolated manner without introducing any
new knobs. Your patch includes his fix as-is without modification
anyway.

> So here is a patch that adds an explicit limit and fixes the
> problem Johannes reported.
> 
> ---8<---
> We currently have no limit on the number of elements in a hash table.
> This is very bad especially considering that some rhashtable users
> had such a limit before the conversion and relied on it for defence
> against DoS attacks.

Which users are you talking about? Both Netlink and TIPC still
have an upper limit. nft sets are controlled by privileged users.

> We already have a maximum hash table size limit but its enforcement
> is only by luck and results in a nasty WARN_ON.

As I stated earlier, this is no longer the case and thus this
paragraph only confuses the commit message.

> This patch adds a new paramater insecure_max_entries which becomes
> the cap on the table.  If unset it defaults to max_size.  If it is
> also zero it means that there is no cap on the number of elements
> in the table.  However, the table will grow whenever the utilisation
> hits 100% and if that growth fails, you will get ENOMEM on insertion.

Last time we discussed this it was said that the caller should enforce
the limit like Netlink does.

I'm fine with adding an upper max but I'd like to discuss that in the
context of a full series which converts all existing enforcements and
also contains a testing mechanism to verify this. Also, unless you can
show me where this is currently a real bug, this is really net-next
material.
