From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: fix verifier issue at check_packet_ptr_add
Date: Fri, 03 Feb 2017 00:46:37 +0100
Message-ID: <5893C4DD.9000701@iogearbox.net>
References: <1486065553-5074-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60498 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751508AbdBBXqj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 18:46:39 -0500
In-Reply-To: <1486065553-5074-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2017 08:59 PM, William Tu wrote:
> When adding a zero value to the packet pointer, the verifer
> reports the following error:
>
> R0=imm0,min_value=0,max_value=0 R1=pkt(id=0,off=0,r=4) R2=pkt_end R3=fp-12 R4=imm4,min_value=4,max_value=4 R5=pkt(id=0,off=4,r=4) R6=ctx R7=imm0,min_value=0,max_value=0 R8=inv,min_value=0,max_value=0 R9=inv R10=fp
> 269: (bf) r2 = r0
> 270: (77) r2 >>= 3
> 271: (bf) r4 = r1
> 272: (0f) r4 += r2
> addition of negative constant to packet pointer is not allowed

How do we get here? I mean compiler is not optimizing this away
as the reg is populated differently from various branches? Could
you elaborate more on that resp. how we end up with this? Thanks!

> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> ---
>   kernel/bpf/verifier.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index fb3513b..1a754e5 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -1397,7 +1397,7 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
>   		imm = insn->imm;
>
>   add_imm:
> -		if (imm <= 0) {
> +		if (imm < 0) {
>   			verbose("addition of negative constant to packet pointer is not allowed\n");
>   			return -EACCES;
>   		}
>
