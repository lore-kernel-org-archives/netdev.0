From: David Miller <davem@davemloft.net>
Subject: Re: more test_progs...
Date: Wed, 26 Apr 2017 22:23:39 -0400 (EDT)
Message-ID: <20170426.222339.1486764869366311464.davem@davemloft.net>
References: <590056F2.5010600@iogearbox.net>
        <20170426.105511.742633353102583622.davem@davemloft.net>
        <cb627763-4df8-13ad-9dfe-88a79cccef64@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35354 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938128AbdD0CXn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 22:23:43 -0400
In-Reply-To: <cb627763-4df8-13ad-9dfe-88a79cccef64@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 26 Apr 2017 16:49:35 -0700

> It's only needed for test_pkt_access.c test,
> since it's being fancy and doing iph->ihl * 4.

It is going to be a common idiom in anything looking at
transport headers, no?

> Also such tcp->urg_ptr access into packed struct is more efficient
> after JITing then sparc's own load_half_unaligned in asm, since it's
> done inline and doesn't need a call.
> 
> Note that such tcphdr workaround is not necessary for more
> real programs: test_l4lb.c and test_xdp.c, since they do:
> if (iph->ihl != 5)
>    return drop;

Hmmm...

> Does sparc64 have some special instructions like that?

Unfortunately not.

I think we need to seriously consider tracking "Pointer
incremented by power of 2 N" and stuff like that.

I know it's not easy, but it is necessary.

Having stuff like the packed thing above is just a completely
unnecessary detail to expose to users writing these programs.
