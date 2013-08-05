From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] fib_trie: remove potential out of bound access
Date: Mon, 5 Aug 2013 15:41:11 -0700
Message-ID: <20130805154111.119ac5ac@nehalam.linuxnetplumber.net>
References: <1375726729.4457.45.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:50121 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755764Ab3HEWlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 18:41:15 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so3903134pbc.35
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 15:41:14 -0700 (PDT)
In-Reply-To: <1375726729.4457.45.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 05 Aug 2013 11:18:49 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> AddressSanitizer [1] dynamic checker pointed a potential
> out of bound access in leaf_walk_rcu()
> 
> We could allocate one more slot in tnode_new() to leave the prefetch()
> in-place but it looks not worth the pain.
> 
> Bug added in commit 82cfbb008572b ("[IPV4] fib_trie: iterator recode")
> 
> [1] :
> https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>

Isn't prefetch supposed to always be safe, even out of bounds; even prefetch(NULL).
Although I really doubt prefetch helps in in this code anyway.
