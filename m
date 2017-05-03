From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests/bpf: add a test case to check
 verifier pointer arithmetic
Date: Wed, 03 May 2017 09:52:37 -0400 (EDT)
Message-ID: <20170503.095237.567083508629913055.davem@davemloft.net>
References: <20170503025814.2787337-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37046 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752080AbdECNwj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 09:52:39 -0400
In-Reply-To: <20170503025814.2787337-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 2 May 2017 19:58:14 -0700

> From: Yonghong Song <yhs@fb.com>
> 
> With clang/llvm 4.0+, the test case is able to generate
> the following pattern:
> ....
> 440: (b7) r1 = 15
> 441: (05) goto pc+73
> 515: (79) r6 = *(u64 *)(r10 -152)
> 516: (bf) r7 = r10
> 517: (07) r7 += -112
> 518: (bf) r2 = r7
> 519: (0f) r2 += r1
> 520: (71) r1 = *(u8 *)(r8 +0)
> 521: (73) *(u8 *)(r2 +45) = r1
> ....
> 
> commit 332270fdc8b6 ("bpf: enhance verifier to understand stack
> pointer arithmetic") improved verifier to handle such a pattern.
> This patch adds a C test case to actually generate such a pattern.
> A dummy tracepoint interface is used to load the program
> into the kernel.
> 
> Signed-off-by: Yonghong Song <yhs@fb.com>
> Acked-by: Martin KaFai Lau <kafai@fb.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied.
