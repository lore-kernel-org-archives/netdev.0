From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: enhance verifier to understand stack
 pointer arithmetic
Date: Sun, 30 Apr 2017 22:57:32 -0400 (EDT)
Message-ID: <20170430.225732.1066032501940701451.davem@davemloft.net>
References: <20170430055242.2536070-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54738 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752815AbdEAC5j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:57:39 -0400
In-Reply-To: <20170430055242.2536070-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Sat, 29 Apr 2017 22:52:42 -0700

> From: Yonghong Song <yhs@fb.com>
> 
> llvm 4.0 and above generates the code like below:
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
> and the verifier complains "R2 invalid mem access 'inv'" for insn #521.
> This is because verifier marks register r2 as unknown value after #519
> where r2 is a stack pointer and r1 holds a constant value.
> 
> Teach verifier to recognize "stack_ptr + imm" and
> "stack_ptr + reg with const val" as valid stack_ptr with new offset.
> 
> Signed-off-by: Yonghong Song <yhs@fb.com>
> Acked-by: Martin KaFai Lau <kafai@fb.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
> technically it's 'net' material, but it's too late for 'net',
> hence 'net-next' tag.
> No 'Fixes' tag, since it's only seen with newer llvm.

Applied to net-next, but I'll queue this up to -stable.
