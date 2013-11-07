From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2 2/3] net_sched: fix some checkpatch errors
Date: Thu, 07 Nov 2013 09:37:52 +0100
Message-ID: <527B5160.5070700@redhat.com>
References: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com> <1383790412-41944-3-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, jhs@mojatatu.com,
	stephen@networkplumber.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36501 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022Ab3KGIiC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 03:38:02 -0500
In-Reply-To: <1383790412-41944-3-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2013 03:13 AM, Yang Yingliang wrote:
> There are some checkpatch errors, fix them.
>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
> ---
>   net/sched/act_api.c     |  5 +++--
>   net/sched/cls_bpf.c     |  2 +-
>   net/sched/cls_u32.c     |  2 +-
>   net/sched/sch_cbq.c     |  3 ++-
>   net/sched/sch_generic.c |  4 ++--
>   net/sched/sch_htb.c     | 13 +++++++------
>   net/sched/sch_netem.c   |  2 +-
>   net/sched/sch_sfq.c     | 10 ++++++----
>   8 files changed, 23 insertions(+), 18 deletions(-)
>
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index fd70728..d92a90e9 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -191,7 +191,8 @@ u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo)
>   			val = 1;
>   	} while (tcf_hash_lookup(val, hinfo));
>
> -	return (*idx_gen = val);
> +	*idx_gen = val;
> +	return *idx_gen;
>   }
>   EXPORT_SYMBOL(tcf_hash_new_index);
>
> @@ -263,7 +264,7 @@ void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo)
>   }
>   EXPORT_SYMBOL(tcf_hash_insert);
>
> -static struct tc_action_ops *act_base = NULL;
> +static struct tc_action_ops *act_base;

 From a readability point of view, I think this makes it worse, also the other places
where you change globals vars like that.

>   static DEFINE_RWLOCK(act_mod_lock);
>
>   int tcf_register_action(struct tc_action_ops *act)
> diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
> index 1002a82..d7c72be 100644
> --- a/net/sched/cls_bpf.c
> +++ b/net/sched/cls_bpf.c
> @@ -323,7 +323,7 @@ static int cls_bpf_dump(struct tcf_proto *tp, unsigned long fh,
>   	if (nla == NULL)
[...]

Also, when you submit v3, I think it would be good if you separate your patch into two
sets: patch1 on its own, and then patch2 and patch3 as an own set as the last two have
not much in common from what's in the cover letter.
