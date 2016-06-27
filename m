From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] notifier: Fix soft lockup for notifier_call_chain().
Date: Mon, 27 Jun 2016 12:50:56 -0700
Message-ID: <CAM_iQpU7mkBFk=AF0kbRZga-nvaE0=nMr-gmn1GJ8WDW-UvO4Q@mail.gmail.com>
References: <576DF09B.6010406@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: luto@kernel.org, Ingo Molnar <mingo@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <576DF09B.6010406@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 24, 2016 at 7:46 PM, Ding Tianhong <dingtianhong@huawei.com> wrote:
> diff --git a/kernel/notifier.c b/kernel/notifier.c
> index fd2c9ac..9c30411 100644
> --- a/kernel/notifier.c
> +++ b/kernel/notifier.c
> @@ -92,6 +92,8 @@ static int notifier_call_chain(struct notifier_block **nl,
>  #endif
>                 ret = nb->notifier_call(nb, val, v);
>
> +               cond_resched();
> +
>                 if (nr_calls)
>                         (*nr_calls)++;

NAK.

You can't do a resched in atomic context in __atomic_notifier_call_chain().
