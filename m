From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: filter: cleanup A/X name usage
Date: Wed, 11 Jun 2014 00:13:38 -0700 (PDT)
Message-ID: <20140611.001338.216529368304427176.davem@davemloft.net>
References: <1402091166-5206-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chema@google.com, edumazet@google.com, dborkman@redhat.com,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752878AbaFKHNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 03:13:39 -0400
In-Reply-To: <1402091166-5206-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri,  6 Jun 2014 14:46:06 -0700

> The macro 'A' used in internal BPF interpreter:
>  #define A regs[insn->a_reg]
> was easily confused with the name of classic BPF register 'A', since
> 'A' would mean two different things depending on context.
> 
> This patch is trying to clean up the naming and clarify its usage in the
> following way:
> 
> - A and X are names of two classic BPF registers
> 
> - BPF_REG_A denotes internal BPF register R0 used to map classic register A
>   in internal BPF programs generated from classic
> 
> - BPF_REG_X denotes internal BPF register R7 used to map classic register X
>   in internal BPF programs generated from classic
> 
> - internal BPF instruction format:
> struct sock_filter_int {
>         __u8    code;           /* opcode */
>         __u8    dst_reg:4;      /* dest register */
>         __u8    src_reg:4;      /* source register */
>         __s16   off;            /* signed offset */
>         __s32   imm;            /* signed immediate constant */
> };
> 
> - BPF_X/BPF_K is 1 bit used to encode source operand of instruction
> In classic:
>   BPF_X - means use register X as source operand
>   BPF_K - means use 32-bit immediate as source operand
> In internal:
>   BPF_X - means use 'src_reg' register as source operand
>   BPF_K - means use 32-bit immediate as source operand
> 
> Suggested-by: Chema Gonzalez <chema@google.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied.
