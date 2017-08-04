From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix byte order test in test_verifier
Date: Fri, 04 Aug 2017 16:09:34 -0700 (PDT)
Message-ID: <20170804.160934.409968216458022252.davem@davemloft.net>
References: <2914429672dfe6d0420a81dff36853326a7f604d.1501877778.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yhs@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41512 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdHDXJf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 19:09:35 -0400
In-Reply-To: <2914429672dfe6d0420a81dff36853326a7f604d.1501877778.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  4 Aug 2017 22:24:41 +0200

> We really must check with #if __BYTE_ORDER == XYZ instead of
> just presence of #ifdef __LITTLE_ENDIAN. I noticed that when
> actually running this on big endian machine, the latter test
> resolves to true for user space, same for #ifdef __BIG_ENDIAN.
> 
> E.g., looking at endian.h from libc, both are also defined
> there, so we really must test this against __BYTE_ORDER instead
> for proper insns selection. For the kernel, such checks are
> fine though e.g. see 13da9e200fe4 ("Revert "endian: #define
> __BYTE_ORDER"") and 415586c9e6d3 ("UAPI: fix endianness conditionals
> in M32R's asm/stat.h") for some more context, but not for
> user space. Lets also make sure to properly include endian.h.
> After that, suite passes for me:
> 
> ./test_verifier: ELF 64-bit MSB executable, [...]
> 
> Linux foo 4.13.0-rc3+ #4 SMP Fri Aug 4 06:59:30 EDT 2017 s390x s390x s390x GNU/Linux
> 
> Before fix: Summary: 505 PASSED, 11 FAILED
> After  fix: Summary: 516 PASSED,  0 FAILED
> 
> Fixes: 18f3d6be6be1 ("selftests/bpf: Add test cases to test narrower ctx field loads")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks!
