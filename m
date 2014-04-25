From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] tools: bpf_dbg: register misuse
Date: Fri, 25 Apr 2014 14:15:19 -0700
Message-ID: <CAADnVQLC305rLy6CObSgUBfwRoAMKLqc8kwO1181_oNEB1XMRw@mail.gmail.com>
References: <CA+Z8YJKFhGQ5QPjMS6PHZnDpGJ7osrCJGDw+AMAPMckKiB8EDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Brendan Hickey <bhickey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:39022 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbaDYVPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 17:15:19 -0400
Received: by mail-qa0-f44.google.com with SMTP id hw13so4094042qab.17
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 14:15:19 -0700 (PDT)
In-Reply-To: <CA+Z8YJKFhGQ5QPjMS6PHZnDpGJ7osrCJGDw+AMAPMckKiB8EDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2014 at 1:52 PM, Brendan Hickey <bhickey@google.com> wrote:
> Hi,
>
> I noticed a mistaken use of the X register instead of the K register
> in bpf_dbg. Enclosed is a fix.

Nice catch!
Please add your signed-off-by.

> Brendan
>
>
> From: Brendan Hickey <bhickey@google.com>
> Date: Fri, 25 Apr 2014 15:54:13 -0400
> Subject: [PATCH] bpf_dbg: Fix erroneous register use for AND
>
> The AND instruction is erroneously using the X register instead of the K
> register.
> ---
>  tools/net/bpf_dbg.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/tools/net/bpf_dbg.c b/tools/net/bpf_dbg.c
> index 65dc757..5e54848 100644
> --- a/tools/net/bpf_dbg.c
> +++ b/tools/net/bpf_dbg.c
> @@ -823,7 +823,7 @@ do_div:
>   r->A &= r->X;
>   break;
>   case BPF_ALU_AND | BPF_K:
> - r->A &= r->X;
> + r->A &= K;
>   break;
>   case BPF_ALU_OR | BPF_X:
>   r->A |= r->X;
>
>
> --
> 1.9.1.423.g4596e3a
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
