From: Martin KaFai Lau <iamkafai@gmail.com>
Subject: Re: [PATCH net] bpf: don't indicate success when copy_from_user fails
Date: Sat, 29 Jul 2017 16:17:35 +0800
Message-ID: <CABx7vpX25+bEkEsOe1RaKmrOOyqgW37deiE-zQQuM3ABodHx5A@mail.gmail.com>
References: <af76c90679bef1488ffb97b9b80f250b6738db57.1501182003.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem@davemloft.net, kafai@fb.com, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:38083 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753402AbdG2IRh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 04:17:37 -0400
Received: by mail-wm0-f67.google.com with SMTP id y206so6755052wmd.5
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 01:17:36 -0700 (PDT)
In-Reply-To: <af76c90679bef1488ffb97b9b80f250b6738db57.1501182003.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 3:02 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> err in bpf_prog_get_info_by_fd() still holds 0 at that time from prior
> check_uarg_tail_zero() check. Explicitly return -EFAULT instead, so
> user space can be notified of buggy behavior.
Thanks for fixing it. (I am on PTO and cannot use my usual email account).

Acked-by: Martin KaFai Lau <kafai@fb.com>

>
> Fixes: 1e2709769086 ("bpf: Add BPF_OBJ_GET_INFO_BY_FD")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  kernel/bpf/syscall.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 045646d..84bb399 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -1289,7 +1289,7 @@ static int bpf_prog_get_info_by_fd(struct bpf_prog *prog,
>         info_len = min_t(u32, sizeof(info), info_len);
>
>         if (copy_from_user(&info, uinfo, info_len))
> -               return err;
> +               return -EFAULT;
>
>         info.type = prog->type;
>         info.id = prog->aux->id;
> --
> 1.9.3
>
