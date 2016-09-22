From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: get rid of an signed integer overflow in
 ip_idents_reserve()
Date: Thu, 22 Sep 2016 02:42:54 -0400 (EDT)
Message-ID: <20160922.024254.1880139496617528792.davem@davemloft.net>
References: <20160920120000.GI1843@nanopsycho.orion>
        <1474378115.23058.2.camel@edumazet-glaptop3.roam.corp.google.com>
        <1474419977.23058.53.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752367AbcIVGnA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 02:43:00 -0400
In-Reply-To: <1474419977.23058.53.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Sep 2016 18:06:17 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Jiri Pirko reported an UBSAN warning happening in ip_idents_reserve()
> 
> [] UBSAN: Undefined behaviour in ./arch/x86/include/asm/atomic.h:156:11
> [] signed integer overflow:
> [] -2117905507 + -695755206 cannot be represented in type 'int'
> 
> Since we do not have uatomic_add_return() yet, use atomic_cmpxchg()
> so that the arithmetics can be done using unsigned int.
> 
> Fixes: 04ca6973f7c1 ("ip: make IP identifiers less predictable")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Jiri Pirko <jiri@resnulli.us>
> ---
> David, Jiri, I removed the prandom_u32() stuff in favor of a traditional
> loop to meet stable requirements. Thanks !

Applied.
