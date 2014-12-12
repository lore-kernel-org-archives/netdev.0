From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] net: sock: correctly handle failed prog retrieval from fd
Date: Thu, 11 Dec 2014 22:34:48 -0800
Message-ID: <CAMEtUuycug_uiK-wjVePTUmO9brMREMWPiYnEMRMdOhWBm2gjw@mail.gmail.com>
References: <1418362428-15067-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418362428-15067-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 11, 2014 at 9:33 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 8cc3c03..ec9baea 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -1103,8 +1103,8 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
>                 return -EPERM;
>
>         prog = bpf_prog_get(ufd);
> -       if (!prog)
> -               return -EINVAL;
> +       if (IS_ERR(prog))
> +               return PTR_ERR(prog);

thank you for the fix, but the same fix is already applied
to net-next and pushed all the way to:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=198bf1b046e370a7d3987b195cff5f1efebec3ac
sorry for the headache that this bug caused.
