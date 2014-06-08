From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: filter: cleanup A/X name usage
Date: Sun, 08 Jun 2014 22:21:31 +0200
Message-ID: <5394C5CB.7050000@redhat.com>
References: <1402091166-5206-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64175 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753986AbaFHUVo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 16:21:44 -0400
In-Reply-To: <1402091166-5206-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2014 11:46 PM, Alexei Starovoitov wrote:
> The macro 'A' used in internal BPF interpreter:
>   #define A regs[insn->a_reg]
> was easily confused with the name of classic BPF register 'A', since
> 'A' would mean two different things depending on context.
>
> This patch is trying to clean up the naming and clarify its usage in the
> following way:
>
> - A and X are names of two classic BPF registers
>
> - BPF_REG_A denotes internal BPF register R0 used to map classic register A
>    in internal BPF programs generated from classic
>
> - BPF_REG_X denotes internal BPF register R7 used to map classic register X
>    in internal BPF programs generated from classic
>
> - internal BPF instruction format:
> struct sock_filter_int {
>          __u8    code;           /* opcode */
>          __u8    dst_reg:4;      /* dest register */
>          __u8    src_reg:4;      /* source register */
>          __s16   off;            /* signed offset */
>          __s32   imm;            /* signed immediate constant */
> };
>
> - BPF_X/BPF_K is 1 bit used to encode source operand of instruction
> In classic:
>    BPF_X - means use register X as source operand
>    BPF_K - means use 32-bit immediate as source operand
> In internal:
>    BPF_X - means use 'src_reg' register as source operand
>    BPF_K - means use 32-bit immediate as source operand
>
> Suggested-by: Chema Gonzalez <chema@google.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>

You could also have mentioned in the changelog that you replace
direct access to ctx pointer with CTX register, it's valid since
we emit a mov from ARG1 to CTX at the beginning which contains
ctx. Anyway, looks good to me.
