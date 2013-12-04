From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] net_sched: Fail if missing mandatory action
 operation methods
Date: Wed, 04 Dec 2013 09:03:50 -0800
Message-ID: <1386176630.30495.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
	 <1386167216-30281-2-git-send-email-jhs@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com, ebiederm@xmission.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:62422 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932703Ab3LDRH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 12:07:26 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so22898543pde.27
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 09:07:25 -0800 (PST)
In-Reply-To: <1386167216-30281-2-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-04 at 09:26 -0500, Jamal Hadi Salim wrote:
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  net/sched/act_api.c |   12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index fd70728..618695e 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -270,6 +270,10 @@ int tcf_register_action(struct tc_action_ops *act)
>  {
>  	struct tc_action_ops *a, **ap;
>  
> +	/* Must supply act, dump, cleanup and init */
> +	if (!act->act || !act->dump || !act->cleanup || !act->init)
> +		return -EINVAL;
> +
>  	write_lock(&act_mod_lock);
>  	for (ap = &act_base; (a = *ap) != NULL; ap = &a->next) {
>  		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
> @@ -381,7 +385,7 @@ int tcf_action_exec(struct sk_buff *skb, const struct tc_action *act,
>  	}
>  	while ((a = act) != NULL) {
>  repeat:
> -		if (a->ops && a->ops->act) {
> +		if (a->ops) {

Could we remove all these tests on a->ops being NULL or not ?

IMHO a->ops cannot be NULL. If NULL, just crash by NULL deref.
