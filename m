From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] net_sched: fix a memory leak in tc action
Date: Mon, 04 Apr 2016 11:07:43 -0700
Message-ID: <1459793263.6473.343.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459791168-16675-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34933 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbcDDSHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 14:07:46 -0400
Received: by mail-pf0-f172.google.com with SMTP id n1so44264945pfn.2
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 11:07:46 -0700 (PDT)
In-Reply-To: <1459791168-16675-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-04 at 10:32 -0700, Cong Wang wrote:
> Fixes: ddf97ccdd7cb ("net_sched: add network namespace support for tc actions")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Tested-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  include/net/act_api.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/net/act_api.h b/include/net/act_api.h
> index 2a19fe1..03e322b 100644
> --- a/include/net/act_api.h
> +++ b/include/net/act_api.h
> @@ -135,6 +135,7 @@ void tcf_hashinfo_destroy(const struct tc_action_ops *ops,
>  static inline void tc_action_net_exit(struct tc_action_net *tn)
>  {
>  	tcf_hashinfo_destroy(tn->ops, tn->hinfo);
> +	kfree(tn->hinfo);
>  }
>  
>  int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,

Looks good to me, although the kfree() might be put in
cf_hashinfo_destroy() (at one place instead of being inlined in all call
points)
