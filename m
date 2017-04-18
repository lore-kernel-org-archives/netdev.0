From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 18 Apr 2017 02:39:01 +0200
Message-ID: <58F56025.40904@iogearbox.net>
References: <20170418101835.745d2576@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170418101835.745d2576@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/18/2017 02:18 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in:
>
>    kernel/bpf/syscall.c
>
> between commits:
>
>    6b1bb01bcc5b ("bpf: fix cb access in socket filter programs on tail calls")
>    c2002f983767 ("bpf: fix checking xdp_adjust_head on tail calls")
>
> from the net tree and commit:
>
>    e245c5c6a565 ("bpf: move fixup_bpf_calls() function")
>    79741b3bdec0 ("bpf: refactor fixup_bpf_calls()")
>
> from the net-next tree.
>
> I fixed it up (the latter moved and changed teh code modified by the
> former  - I added the following fix up patch) and can carry the fix as
> necessary. This is now fixed as far as linux-next is concerned, but any
> non trivial conflicts should be mentioned to your upstream maintainer
> when your tree is submitted for merging.  You may also want to consider
> cooperating with the maintainer of the conflicting tree to minimise any
> particularly complex conflicts.
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 18 Apr 2017 10:16:03 +1000
> Subject: [PATCH] bpf: merge fix for move of fixup_bpf_calls()
>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>   kernel/bpf/verifier.c | 8 ++++++++
>   1 file changed, 8 insertions(+)
>
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 62e1e447ded9..5939b4c81fe1 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -3349,6 +3349,14 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
>   		if (insn->imm == BPF_FUNC_xdp_adjust_head)
>   			prog->xdp_adjust_head = 1;
>   		if (insn->imm == BPF_FUNC_tail_call) {
> +			/* If we tail call into other programs, we
> +			 * cannot make any assumptions since they
> +			 * can be replaced dynamically during runtime
> +			 * in the program array.
> +			 */
> +			prog->cb_access = 1;
> +			prog->xdp_adjust_head = 1;
> +
>   			/* mark bpf_tail_call as different opcode to avoid
>   			 * conditional branch in the interpeter for every normal
>   			 * call and to prevent accidental JITing by JIT compiler
>

Looks good, thanks.
