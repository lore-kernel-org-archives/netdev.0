From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] geneve: avoid use-after-free of skb->data
Date: Sat, 03 Dec 2016 23:11:38 -0500 (EST)
Message-ID: <20161203.231138.1619556323782350736.davem@davemloft.net>
References: <027c88dd060f5ca4535cb346db125829b2181a88.1480675406.git.sd@queasysnail.net>
        <20161202.140925.1784959728501874377.davem@davemloft.net>
        <20161203003326.GA27610@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752092AbcLDELk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 23:11:40 -0500
In-Reply-To: <20161203003326.GA27610@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Sat, 3 Dec 2016 01:33:26 +0100

> I'd like to try something based on static analysis. We'd need a way to
> tag cached pointers to skb->data (via ip_hdr() or whatever), and
> propagate the notion that pskb_expand_head() makes these cached
> pointers stale through layers of function calls.  I don't know how
> feasible this is with the tools we have.

Perhaps create helpers that have some special attribute attached to
them like "skb_volatile" or whatever.  ip_hdr() et al would go through
them.

Then the static analysis tool is told that pskb_expand_head() "kills"
all skb_volatile obtained values, and it could basically mark all such
variables as uninitialized.
