From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fib_trie: remove potential out of bound access
Date: Mon, 05 Aug 2013 16:00:56 -0700
Message-ID: <1375743656.4457.48.camel@edumazet-glaptop>
References: <1375726729.4457.45.camel@edumazet-glaptop>
	 <20130805154111.119ac5ac@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34574 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129Ab3HEXA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 19:00:58 -0400
Received: by mail-pa0-f49.google.com with SMTP id bi5so3881500pad.22
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 16:00:57 -0700 (PDT)
In-Reply-To: <20130805154111.119ac5ac@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-05 at 15:41 -0700, Stephen Hemminger wrote:
> On Mon, 05 Aug 2013 11:18:49 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > AddressSanitizer [1] dynamic checker pointed a potential
> > out of bound access in leaf_walk_rcu()
> > 
> > We could allocate one more slot in tnode_new() to leave the prefetch()
> > in-place but it looks not worth the pain.
> > 
> > Bug added in commit 82cfbb008572b ("[IPV4] fib_trie: iterator recode")
> > 
> > [1] :
> > https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel
> > 
> > Reported-by: Andrey Konovalov <andreyknvl@google.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Dmitry Vyukov <dvyukov@google.com>
> 
> Isn't prefetch supposed to always be safe, even out of bounds; even prefetch(NULL).
> Although I really doubt prefetch helps in in this code anyway.


prefetch(...) was not the problem here.

The problem was X = array[N]   with N being >= size(array)
