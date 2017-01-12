From: Quentin Monnet <quentin.monnet@6wind.com>
Subject: Re: [PATCH net-next 2/2] bpf: allow b/h/w/dw access for bpf's cb in
 ctx
Date: Thu, 12 Jan 2017 09:25:20 +0100
Message-ID: <bb078a63-6bcc-22f8-c98e-8445f66678c9@6wind.com>
References: <cover.1484182858.git.daniel@iogearbox.net>
 <fff467f83e48c6c15053a7637893bf247c9be102.1484182858.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35559 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750768AbdALI0P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 03:26:15 -0500
Received: by mail-wm0-f52.google.com with SMTP id r126so9740867wmr.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 00:25:28 -0800 (PST)
In-Reply-To: <fff467f83e48c6c15053a7637893bf247c9be102.1484182858.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

2017-01-12 (02:21 +0100) ~ Daniel Borkmann <daniel@iogearbox.net>
> When structs are used to store temporary state in cb[] buffer that is
> used with programs and among tail calls, then the generated code will
> not always access the buffer in bpf_w chunks. We can ease programming
> of it and let this act more natural by allowing for aligned b/h/w/dw
> sized access for cb[] ctx member. Various test cases are attached as
> well for the selftest suite. Potentially, this can also be reused for
> other program types to pass data around.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  kernel/bpf/verifier.c                       |   8 +-
>  net/core/filter.c                           |  41 ++-
>  tools/testing/selftests/bpf/test_verifier.c | 442 +++++++++++++++++++++++++++-
>  3 files changed, 478 insertions(+), 13 deletions(-)
> 

[...]

> diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
> index 9bb4534..f664bed 100644
> --- a/tools/testing/selftests/bpf/test_verifier.c
> +++ b/tools/testing/selftests/bpf/test_verifier.c
> @@ -859,15 +859,451 @@ struct test_val {

[...]

> +	{
> +		"check cb access: doulbe, oob 5",
> +		.insns = {
> +			BPF_MOV64_IMM(BPF_REG_0, 0),
> +			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
> +				    offsetof(struct __sk_buff, cb[4]) + 8),
> +			BPF_EXIT_INSN(),
> +		},
> +		.errstr = "invalid bpf_context access",
> +		.result = REJECT,
> +	},

Nitpicking: typo ("doulbe").

Regards,
Quentin
