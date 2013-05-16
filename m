From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC/BUG] ipv6: bug in "ipv6: Copy cork options in ip6_append_data"
Date: Thu, 16 May 2013 15:23:10 -0700
Message-ID: <1368742990.3301.67.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:42600 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754945Ab3EPWXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 18:23:13 -0400
Received: by mail-pd0-f177.google.com with SMTP id g10so2723826pdj.22
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 15:23:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert

Looking at the code added in commit 0178b695fd6b40a62a215cb
("ipv6: Copy cork options in ip6_append_data") it looks like we can have
either a memleak or corruption (later in ip6_cork_release()) in case one
of the sub-allocation (ip6_opt_dup()/ip6_rthdr_dup()) fails.

I would at least use a kzalloc() instead of kmalloc() in 

np->cork.opt = kmalloc(opt->tot_len, sk->sk_allocation);

Or maybe better, reuse the code in  ipv6_dup_options() so that we
perform a single memory allocation ?

Am I missing something obvious ?

Thanks !
