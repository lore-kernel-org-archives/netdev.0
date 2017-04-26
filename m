From: David Miller <davem@davemloft.net>
Subject: Re: hmmm...
Date: Wed, 26 Apr 2017 13:25:48 -0400 (EDT)
Message-ID: <20170426.132548.1260374401411231348.davem@davemloft.net>
References: <af3781d2-f8af-1c6e-b3a0-163d8c1de75a@fb.com>
        <20170425.233820.1357836307906136732.davem@davemloft.net>
        <133d8e46-c5c1-1e0e-86a1-a7b5a2737bff@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58442 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753035AbdDZRZw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 13:25:52 -0400
In-Reply-To: <133d8e46-c5c1-1e0e-86a1-a7b5a2737bff@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 25 Apr 2017 22:31:06 -0700

> On 4/25/17 8:38 PM, David Miller wrote:
> jgt/jge/jsgt/sge was a stumbling block for me as well,
> since it still takes me longer than necessary to disambiguate
> into > vs >= and signed/unsigned

I had this problem while writing Sparc JIT :)

> Though I think Daniel still prefers old classic bpf asm ;)

I do too.

> Anyway, back to the question...
> since BFD and GCC are so much entrenched into canonical style
> of asm code, I don't mind that gnu toolchain will be using it.

Ok.  All data flows from right to left in the instructions so it will
be familiar for x86 assembler hackers.

> I like that you used 'dw' in 'ldxdw' instead of just 'd'
> though 'x' can probably be dropped.

Ok, dropped.

> 'x' should be added here instead:
>  { "stb", BPF_OPC_ST    | BPF_OPC_MEM  | BPF_OPC_B, "[1+O],i" },
>  { "stb", BPF_OPC_STX   | BPF_OPC_MEM  | BPF_OPC_B, "[1+O],2" },

The 'x' really isn't necessary, I would say.  Assembler can tell from
context whether immediate or register variant is wanted and thus:

	stb	[r1+8], 2
	stb	[r1+8], r4

are both assembled correctly.
