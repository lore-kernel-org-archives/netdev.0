From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Thu, 04 May 2017 09:37:23 -0400 (EDT)
Message-ID: <20170504.093723.1592226593887244452.davem@davemloft.net>
References: <6a5fa930-cb76-8eee-94c7-7c5fe8fb8cdc@fb.com>
        <20170503.133512.310640909764585408.davem@davemloft.net>
        <d809baa4-c864-af99-38af-fbcb6637ca2b@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54478 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753141AbdEDNhZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 09:37:25 -0400
In-Reply-To: <d809baa4-c864-af99-38af-fbcb6637ca2b@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 3 May 2017 20:30:22 -0700

> I would buy that debian folks indeed care about multi-arch, but
> what above does is making #include <linux/types.h> to be a nop
> for any cross-compiler on sparc that included it.

No, if you installed cross compiler for arch X it would add
another stanza doing that "ifdef __ARCH__, include blah, endif"
dance.

> You're right that we cannot assume much about /usr/include craziness.
> In that sense adding __native_arch__ macro is also wrong, since
> it assumes sane /usr/include without inline asm or other things
> that clang for bpf arch can consume.

You can assume that it's for the ARCH we are trying to run tests
for, which needs to be in the family of the kernel arch.

> In that sense the only way to be independent from arch dependent
> things in /usr/include is to put all arch specific headers
> into our own dir in tools/selftests/ (or may be tools/bpf/include)
> and point clang to that. I think the list of .h in there will be
> limited. Only things like linux/types.h and gnu/stubs.h,
> so it will be manageable.
> Thoughts?

No, this way lies madness.

If you want to get the kernel headers, set up the proper environment
instead of constantly trying to fight it.
