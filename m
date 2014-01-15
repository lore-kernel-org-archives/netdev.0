From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: act: fix a bug in tcf_register_action()
Date: Wed, 15 Jan 2014 07:34:49 -0500
Message-ID: <52D68069.1090804@mojatatu.com>
References: <1389739694-9251-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:55917 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbaAOMfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 07:35:07 -0500
Received: by mail-ie0-f178.google.com with SMTP id x13so1982182ief.37
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 04:35:06 -0800 (PST)
In-Reply-To: <1389739694-9251-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/14 17:48, Cong Wang wrote:
> In tcf_register_action() we check ->type and ->kind to see if there
> is an existing action registered, but ipt action registers two
> actions with same type but different kinds. This should be a valid
> case, otherwise only xt can be registered.
>


We cant allow for conflicts by name or id - we want to catch them.
So just introduce TCA_ACT_XT instead (ID 7)

[
Note: iptables used to be a constant moving API target
and this is supposed to be the latest "backward compat mode".
New kernel/iproute ==> We want to love "xt" more than "ipt".
We infact want to eventually kill "ipt".
but this preference is hard to achieve as you may have run into.
I would be curious how you tested and run into this..
].

cheers,
jamal

> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> ---
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index 35f89e9..2070ee3 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -273,7 +273,7 @@ int tcf_register_action(struct tc_action_ops *act)
>
>   	write_lock(&act_mod_lock);
>   	list_for_each_entry(a, &act_base, head) {
> -		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
> +		if (act->type == a->type && (strcmp(act->kind, a->kind) == 0)) {
>   			write_unlock(&act_mod_lock);
>   			return -EEXIST;
>   		}
>
