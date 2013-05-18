From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: can call module_free()
 from any context
Date: Fri, 17 May 2013 18:29:35 -0700 (PDT)
Message-ID: <20130517.182935.208791672952634187.davem@davemloft.net>
References: <1368769530.3301.81.camel@edumazet-glaptop>
	<20130517.141952.581871611521516663.davem@davemloft.net>
	<1368829366.3301.121.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@ZenIV.linux.org.uk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642Ab3ERB3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 21:29:36 -0400
In-Reply-To: <1368829366.3301.121.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 May 2013 15:22:46 -0700

> I am considering adding ReadOnly protection to the pages containing BPF
> generated code, like we do for modules text if
> CONFIG_DEBUG_SET_MODULE_RONX=y
> 
> Should we have an option to configure this, driven by HAVE_BPF_JIT_RO,
> or should we do the RO thing in all cases (ie not adding yet another
> Kconfig stuff)

I think we should do this unconditionally, it'll be noise as far as
overhead during filter compilation.

> Another ongoing work is to add some protection against BPF JIT spraying
> attacks
> ( http://mainisusuallyafunction.blogspot.com/2012/11/attacking-hardened-linux-systems-with.html )
> 
> My idea would be to have a hole of random size before the code, filled
> with 0xcc (int3) opcodes. Since we allocate a multiple of PAGE_SIZE
> anyway, we have plenty of available space to play with.

This sounds like a good idea too.
