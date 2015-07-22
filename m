From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2] cgroup: net_cls: fix false-positive "suspicious RCU
 usage"
Date: Wed, 22 Jul 2015 13:56:44 +0200
Message-ID: <55AF84FC.2070502@iogearbox.net>
References: <20150721164629.18385.14538.stgit@buzz> <20150722092320.30663.86742.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org,
	Li Zefan <lizefan@huawei.com>, linux-kernel@vger.kernel.org
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150722092320.30663.86742.stgit@buzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/22/2015 11:23 AM, Konstantin Khlebnikov wrote:
> In dev_queue_xmit() net_cls protected with rcu-bh.
...
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>   net/core/netclassid_cgroup.c |    3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
> index 1f2a126f4ffa..6441f47b1a8f 100644
> --- a/net/core/netclassid_cgroup.c
> +++ b/net/core/netclassid_cgroup.c
> @@ -23,7 +23,8 @@ static inline struct cgroup_cls_state *css_cls_state(struct cgroup_subsys_state
>
>   struct cgroup_cls_state *task_cls_state(struct task_struct *p)
>   {
> -	return css_cls_state(task_css(p, net_cls_cgrp_id));
> +	return css_cls_state(task_css_check(p, net_cls_cgrp_id,
> +					    rcu_read_lock_bh_held()));

Did you also check that after your patch this doesn't trigger on ingress
either? There, this code path could be invoked under rcu_read_lock(). So,
perhaps you need to check for both.

>   }
>   EXPORT_SYMBOL_GPL(task_cls_state);
