From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/3] bpf: Don't check for current being NULL
Date: Mon, 16 Oct 2017 15:06:08 -0700
Message-ID: <CAADnVQJzM3DH_gxAwo2mnGiv7bOsip1TAFF8YGPLx-dqSb1SPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2017 at 11:18 AM, Richard Weinberger <richard@nod.at> wrote:
> current is never NULL.
>
> Signed-off-by: Richard Weinberger <richard@nod.at>
> ---
>  kernel/bpf/helpers.c | 12 ------------
>  1 file changed, 12 deletions(-)
>
> diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
> index 3d24e238221e..e8845adcd15e 100644
> --- a/kernel/bpf/helpers.c
> +++ b/kernel/bpf/helpers.c
> @@ -120,9 +120,6 @@ BPF_CALL_0(bpf_get_current_pid_tgid)
>  {
>         struct task_struct *task = current;
>
> -       if (unlikely(!task))
> -               return -EINVAL;
> -

really? in all context? including irq and nmi?
