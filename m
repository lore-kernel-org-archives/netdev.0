From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: filter: rename 'struct sock_filter_int'
 into 'struct bpf_insn'
Date: Fri, 25 Jul 2014 01:21:21 +0200
Message-ID: <53D194F1.6020603@redhat.com>
References: <1406237179-3713-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406237179-3713-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/24/2014 11:26 PM, Alexei Starovoitov wrote:
> eBPF is used by socket filtering, seccomp and soon by tracing and
> exposed to userspace, therefore 'sock_filter_int' name is not accurate.
> Rename it to 'bpf_insn'
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
...
>   #define BPF_ALU64_REG(OP, DST, SRC)				\
> -	((struct sock_filter_int) {				\
> +	((struct bpf_insn) {				\

                              ^^^ Please also fix up whitespacing here
                                  and all the other sections below.

>   		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_X,	\
>   		.dst_reg = DST,					\
>   		.src_reg = SRC,					\
> @@ -90,7 +90,7 @@ enum {
>   		.imm   = 0 })
>
>   #define BPF_ALU32_REG(OP, DST, SRC)				\
> -	((struct sock_filter_int) {				\
> +	((struct bpf_insn) {				\
>   		.code  = BPF_ALU | BPF_OP(OP) | BPF_X,		\
>   		.dst_reg = DST,					\
>   		.src_reg = SRC,					\
> @@ -100,7 +100,7 @@ enum {
>   /* ALU ops on immediates, bpf_add|sub|...: dst_reg += imm32 */
>
>   #define BPF_ALU64_IMM(OP, DST, IMM)				\
> -	((struct sock_filter_int) {				\
> +	((struct bpf_insn) {				\
>   		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_K,	\
>   		.dst_reg = DST,					\
>   		.src_reg = 0,					\
> @@ -108,7 +108,7 @@ enum {
>   		.imm   = IMM })
>
>   #define BPF_ALU32_IMM(OP, DST, IMM)				\
> -	((struct sock_filter_int) {				\
> +	((struct bpf_insn) {				\
>   		.code  = BPF_ALU | BPF_OP(OP) | BPF_K,		\
>   		.dst_reg = DST,					\
>   		.src_reg = 0,					\
> @@ -118,7 +118,7 @@ enum {
>   /* Endianess conversion, cpu_to_{l,b}e(), {l,b}e_to_cpu() */
>
>   #define BPF_ENDIAN(TYPE, DST, LEN)				\
> -	((struct sock_filter_int) {				\
> +	((struct bpf_insn) {				\
>   		.code  = BPF_ALU | BPF_END | BPF_SRC(TYPE),	\
>   		.dst_reg = DST,					\
>   		.src_reg = 0,					\
> @@ -128,7 +128,7 @@ enum {
>   /* Short form of mov, dst_reg = src_reg */
>
>   #define BPF_MOV64_REG(DST, SRC)					\
> -	((struct sock_filter_int) {				\
> +	((struct bpf_insn) {				\
>   		.code  = BPF_ALU64 | BPF_MOV | BPF_X,		\
>   		.dst_reg = DST,					\
>   		.src_reg = SRC,					\
> @@ -136,7 +136,7 @@ enum {
>   		.imm   = 0 })
>
>   #define BPF_MOV32_REG(DST, SRC)					\
> -	((struct sock_filter_int) {				\
> +	((struct bpf_insn) {				\
>   		.code  = BPF_ALU | BPF_MOV | BPF_X,		\
>   		.dst_reg = DST,					\
>   		.src_reg = SRC,					\
....
