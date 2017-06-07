From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH net] bpf, arm64: use separate register for state in stxr
Date: Wed, 7 Jun 2017 12:51:31 +0100
Message-ID: <20170607115131.GA30263@arm.com>
References: <530443d87bd51b3682a1b60ea19b2030d7d21409.1496834547.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ast@fb.com, zlim.lnx@gmail.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:59864 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751414AbdFGLvY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 07:51:24 -0400
Content-Disposition: inline
In-Reply-To: <530443d87bd51b3682a1b60ea19b2030d7d21409.1496834547.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On Wed, Jun 07, 2017 at 01:45:37PM +0200, Daniel Borkmann wrote:
> Will reported that in BPF_XADD we must use a different register in stxr
> instruction for the status flag due to otherwise CONSTRAINED UNPREDICTABLE
> behavior per architecture. Reference manual says [1]:
> 
>   If s == t, then one of the following behaviors must occur:
> 
>    * The instruction is UNDEFINED.
>    * The instruction executes as a NOP.
>    * The instruction performs the store to the specified address, but
>      the value stored is UNKNOWN.
> 
> Thus, use a different temporary register for the status flag to fix it.
> 
> Disassembly extract from test 226/STX_XADD_DW from test_bpf.ko:
> 
>   [...]
>   0000003c:  c85f7d4b  ldxr x11, [x10]
>   00000040:  8b07016b  add x11, x11, x7
>   00000044:  c80c7d4b  stxr w12, x11, [x10]
>   00000048:  35ffffac  cbnz w12, 0x0000003c
>   [...]
> 
>   [1] https://static.docs.arm.com/ddi0487/b/DDI0487B_a_armv8_arm.pdf, p.6132
> 
> Fixes: 85f68fe89832 ("bpf, arm64: implement jiting of BPF_XADD")
> Reported-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  arch/arm64/net/bpf_jit_comp.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)

Cheers for fixing this up:

Acked-by: Will Deacon <will.deacon@arm.com>

Will
