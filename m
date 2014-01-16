From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: act: remove capab from struct tc_action_ops
Date: Thu, 16 Jan 2014 08:30:07 -0500
Message-ID: <52D7DEDF.6050006@mojatatu.com>
References: <1389829770-811-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:49559 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbaAPNaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 08:30:09 -0500
Received: by mail-ig0-f180.google.com with SMTP id m12so7568912iga.1
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 05:30:09 -0800 (PST)
In-Reply-To: <1389829770-811-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/14 18:49, Cong Wang wrote:
> It is not actually implemented.

Why dont you do something more useful like allow user to
query capability?
If that doesnt make sense - lets talk offline.

cheers,
jamal

>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   include/net/act_api.h   | 2 --
>   net/sched/act_csum.c    | 1 -
>   net/sched/act_gact.c    | 1 -
>   net/sched/act_ipt.c     | 2 --
>   net/sched/act_mirred.c  | 1 -
>   net/sched/act_nat.c     | 1 -
>   net/sched/act_pedit.c   | 1 -
>   net/sched/act_police.c  | 1 -
>   net/sched/act_simple.c  | 1 -
>   net/sched/act_skbedit.c | 1 -
>   10 files changed, 12 deletions(-)
>
> diff --git a/include/net/act_api.h b/include/net/act_api.h
> index e171387..8ed9746 100644
> --- a/include/net/act_api.h
> +++ b/include/net/act_api.h
> @@ -81,13 +81,11 @@ struct tc_action {
>   	struct list_head	list;
>   };
>
> -#define TCA_CAP_NONE 0
>   struct tc_action_ops {
>   	struct list_head head;
>   	struct tcf_hashinfo *hinfo;
>   	char    kind[IFNAMSIZ];
>   	__u32   type; /* TBD to match kind */
> -	__u32 	capab;  /* capabilities includes 4 bit version */
>   	struct module		*owner;
>   	int     (*act)(struct sk_buff *, const struct tc_action *, struct tcf_result *);
>   	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
> diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
> index ee28e1c..9d5c1d3 100644
> --- a/net/sched/act_csum.c
> +++ b/net/sched/act_csum.c
> @@ -572,7 +572,6 @@ static struct tc_action_ops act_csum_ops = {
>   	.kind		= "csum",
>   	.hinfo		= &csum_hash_info,
>   	.type		= TCA_ACT_CSUM,
> -	.capab		= TCA_CAP_NONE,
>   	.owner		= THIS_MODULE,
>   	.act		= tcf_csum,
>   	.dump		= tcf_csum_dump,
> diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
> index 3133307..72c49de 100644
> --- a/net/sched/act_gact.c
> +++ b/net/sched/act_gact.c
> @@ -194,7 +194,6 @@ static struct tc_action_ops act_gact_ops = {
>   	.kind		=	"gact",
>   	.hinfo		=	&gact_hash_info,
>   	.type		=	TCA_ACT_GACT,
> -	.capab		=	TCA_CAP_NONE,
>   	.owner		=	THIS_MODULE,
>   	.act		=	tcf_gact,
>   	.dump		=	tcf_gact_dump,
> diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
> index bc9f498..67d701e 100644
> --- a/net/sched/act_ipt.c
> +++ b/net/sched/act_ipt.c
> @@ -287,7 +287,6 @@ static struct tc_action_ops act_ipt_ops = {
>   	.kind		=	"ipt",
>   	.hinfo		=	&ipt_hash_info,
>   	.type		=	TCA_ACT_IPT,
> -	.capab		=	TCA_CAP_NONE,
>   	.owner		=	THIS_MODULE,
>   	.act		=	tcf_ipt,
>   	.dump		=	tcf_ipt_dump,
> @@ -299,7 +298,6 @@ static struct tc_action_ops act_xt_ops = {
>   	.kind		=	"xt",
>   	.hinfo		=	&ipt_hash_info,
>   	.type		=	TCA_ACT_XT,
> -	.capab		=	TCA_CAP_NONE,
>   	.owner		=	THIS_MODULE,
>   	.act		=	tcf_ipt,
>   	.dump		=	tcf_ipt_dump,
> diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
> index 5d05b57..376234e 100644
> --- a/net/sched/act_mirred.c
> +++ b/net/sched/act_mirred.c
> @@ -257,7 +257,6 @@ static struct tc_action_ops act_mirred_ops = {
>   	.kind		=	"mirred",
>   	.hinfo		=	&mirred_hash_info,
>   	.type		=	TCA_ACT_MIRRED,
> -	.capab		=	TCA_CAP_NONE,
>   	.owner		=	THIS_MODULE,
>   	.act		=	tcf_mirred,
>   	.dump		=	tcf_mirred_dump,
> diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
> index a49fa23..46e1aa3 100644
> --- a/net/sched/act_nat.c
> +++ b/net/sched/act_nat.c
> @@ -296,7 +296,6 @@ static struct tc_action_ops act_nat_ops = {
>   	.kind		=	"nat",
>   	.hinfo		=	&nat_hash_info,
>   	.type		=	TCA_ACT_NAT,
> -	.capab		=	TCA_CAP_NONE,
>   	.owner		=	THIS_MODULE,
>   	.act		=	tcf_nat,
>   	.dump		=	tcf_nat_dump,
> diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
> index f361e4e..109265d 100644
> --- a/net/sched/act_pedit.c
> +++ b/net/sched/act_pedit.c
> @@ -233,7 +233,6 @@ static struct tc_action_ops act_pedit_ops = {
>   	.kind		=	"pedit",
>   	.hinfo		=	&pedit_hash_info,
>   	.type		=	TCA_ACT_PEDIT,
> -	.capab		=	TCA_CAP_NONE,
>   	.owner		=	THIS_MODULE,
>   	.act		=	tcf_pedit,
>   	.dump		=	tcf_pedit_dump,
> diff --git a/net/sched/act_police.c b/net/sched/act_police.c
> index a719fdf..7fd0993 100644
> --- a/net/sched/act_police.c
> +++ b/net/sched/act_police.c
> @@ -385,7 +385,6 @@ static struct tc_action_ops act_police_ops = {
>   	.kind		=	"police",
>   	.hinfo		=	&police_hash_info,
>   	.type		=	TCA_ID_POLICE,
> -	.capab		=	TCA_CAP_NONE,
>   	.owner		=	THIS_MODULE,
>   	.act		=	tcf_act_police,
>   	.dump		=	tcf_act_police_dump,
> diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
> index f7d5406..92236da 100644
> --- a/net/sched/act_simple.c
> +++ b/net/sched/act_simple.c
> @@ -190,7 +190,6 @@ static struct tc_action_ops act_simp_ops = {
>   	.kind		=	"simple",
>   	.hinfo		=	&simp_hash_info,
>   	.type		=	TCA_ACT_SIMP,
> -	.capab		=	TCA_CAP_NONE,
>   	.owner		=	THIS_MODULE,
>   	.act		=	tcf_simp,
>   	.dump		=	tcf_simp_dump,
> diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
> index 74af461..c36b520 100644
> --- a/net/sched/act_skbedit.c
> +++ b/net/sched/act_skbedit.c
> @@ -189,7 +189,6 @@ static struct tc_action_ops act_skbedit_ops = {
>   	.kind		=	"skbedit",
>   	.hinfo		=	&skbedit_hash_info,
>   	.type		=	TCA_ACT_SKBEDIT,
> -	.capab		=	TCA_CAP_NONE,
>   	.owner		=	THIS_MODULE,
>   	.act		=	tcf_skbedit,
>   	.dump		=	tcf_skbedit_dump,
>
