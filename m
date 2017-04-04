From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: use 'ctx' instead of 'skb' in debug message
Date: Tue, 04 Apr 2017 19:26:19 +0200
Message-ID: <58E3D73B.5050806@iogearbox.net>
References: <20170404144608.27382-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41332 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754280AbdDDR00 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 13:26:26 -0400
In-Reply-To: <20170404144608.27382-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2017 04:46 PM, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
>
> The error message here should mention 'ctx' since the context
> is now more generic than just an skb.
>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>   kernel/bpf/verifier.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 796b68d00119..1b3c921d3798 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -2329,7 +2329,7 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
>   		return err;
>
>   	if (regs[BPF_REG_6].type != PTR_TO_CTX) {
> -		verbose("at the time of BPF_LD_ABS|IND R6 != pointer to skb\n");
> +		verbose("at the time of BPF_LD_ABS|IND R6 != pointer to ctx\n");
>   		return -EINVAL;

Seems okay, the reason why we had 'skb' in the verbose message here is
due to BPF_LD + BPF_ABS/BPF_IND operations being only specific to skbs
and no other context (see __bpf_prog_run(), and in verifier may_access_skb()
check before that verbose() message in check_ld_abs()). Reason for this
is mostly historical due to the cBPF to eBPF migration so that these loads
don't get slowed down when migrated to eBPF and can be handled by JIT
optimizations (e.g., caching skb->data), too. Anyway, just to provide
some more background on this. I've no strong opinion if you want to change
the verifier error message, so:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
