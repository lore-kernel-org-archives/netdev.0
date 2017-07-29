From: Martin KaFai Lau <iamkafai@gmail.com>
Subject: Re: [PATCH net] bpf: fix bpf_prog_get_info_by_fd to dump correct xlated_prog_len
Date: Sat, 29 Jul 2017 16:18:45 +0800
Message-ID: <CABx7vpXpGxQmEOz70m_W8Wv8czFr2sXj9fDFpSL4Sdb6n3m+RA@mail.gmail.com>
References: <a88afb3f19e16a937683bc2bfa80100144fb3792.1501254197.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem@davemloft.net, kafai@fb.com, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33033 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753356AbdG2ISr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 04:18:47 -0400
Received: by mail-wm0-f65.google.com with SMTP id q189so18670646wmd.0
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 01:18:46 -0700 (PDT)
In-Reply-To: <a88afb3f19e16a937683bc2bfa80100144fb3792.1501254197.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 11:05 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> bpf_prog_size(prog->len) is not the correct length we want to dump
> back to user space. The code in bpf_prog_get_info_by_fd() uses this
> to copy prog->insnsi to user space, but bpf_prog_size(prog->len) also
> includes the size of struct bpf_prog itself plus program instructions
> and is usually used either in context of accounting or for bpf_prog_alloc()
> et al, thus we copy out of bounds in bpf_prog_get_info_by_fd()
> potentially. Use the correct bpf_prog_insn_size() instead.
Acked-by: Martin KaFai Lau <kafai@fb.com>

>
> Fixes: 1e2709769086 ("bpf: Add BPF_OBJ_GET_INFO_BY_FD")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  kernel/bpf/syscall.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 84bb399..6c772ad 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -1312,7 +1312,7 @@ static int bpf_prog_get_info_by_fd(struct bpf_prog *prog,
>         }
>
>         ulen = info.xlated_prog_len;
> -       info.xlated_prog_len = bpf_prog_size(prog->len);
> +       info.xlated_prog_len = bpf_prog_insn_size(prog);
>         if (info.xlated_prog_len && ulen) {
>                 uinsns = u64_to_user_ptr(info.xlated_prog_insns);
>                 ulen = min_t(u32, info.xlated_prog_len, ulen);
> --
> 1.9.3
>
