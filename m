From: Li Zefan <lizefan@huawei.com>
Subject: Re: [PATCH v2 01/10] cgroup: net_cls: Use empty task_cls_classid()
 when !CONFIG_NET_CLS(_MODULE)
Date: Mon, 27 Aug 2012 10:32:55 +0800
Message-ID: <503ADC57.70602@huawei.com>
References: <1345816904-21745-1-git-send-email-wagi@monom.org> <1345816904-21745-2-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <cgroups@vger.kernel.org>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: Daniel Wagner <wagi@monom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:52442 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873Ab2H0CdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Aug 2012 22:33:24 -0400
In-Reply-To: <1345816904-21745-2-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

task_cls_classid() is called by sock_update_classid().

#ifdef CONFIG_CGROUPS
extern void sock_update_classid(struct sock *sk);
#else
static inline void sock_update_classid(struct sock *sk)
{
}
#endif

Change to define sock_update_classid() only when CONFIG_NET_CLS is enabled, and
then we don't need this patch, and the code will be simpler.

On 2012/8/24 22:01, Daniel Wagner wrote:
> From: Daniel Wagner <daniel.wagner@bmw-carit.de>
> 
> Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Li Zefan <lizefan@huawei.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: netdev@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> ---
>  include/net/cls_cgroup.h | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
> index a4dc5b0..e2fe2b9 100644
> --- a/include/net/cls_cgroup.h
> +++ b/include/net/cls_cgroup.h
> @@ -24,7 +24,8 @@ struct cgroup_cls_state
>  	u32 classid;
>  };
>  
> -#ifdef CONFIG_NET_CLS_CGROUP
> +#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
> +
>  static inline u32 task_cls_classid(struct task_struct *p)
>  {
>  	int classid;
> @@ -39,7 +40,9 @@ static inline u32 task_cls_classid(struct task_struct *p)
>  
>  	return classid;
>  }
> -#else
> +
> +#elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
> +
>  extern int net_cls_subsys_id;
>  
>  static inline u32 task_cls_classid(struct task_struct *p)
> @@ -60,11 +63,16 @@ static inline u32 task_cls_classid(struct task_struct *p)
>  
>  	return classid;
>  }
> -#endif
> +
>  #else
> +
>  static inline u32 task_cls_classid(struct task_struct *p)
>  {
>  	return 0;
>  }
> -#endif
> +
> +#endif /* CONFIG_NET_CLS_CGROUP */
> +
> +#endif /* CONFIG_CGROURPS */
> +
>  #endif  /* _NET_CLS_CGROUP_H */
> 
