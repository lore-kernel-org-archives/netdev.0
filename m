From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/1] net sched filters: fix notification of filter
 delete with proper handle
Date: Mon, 24 Oct 2016 00:30:44 +0200
Message-ID: <580D3A14.5010705@iogearbox.net>
References: <1477236912-5789-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34176 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754380AbcJWWat (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 18:30:49 -0400
In-Reply-To: <1477236912-5789-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2016 05:35 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>

An actual commit message would be good especially if it's a fix
for -net tree plus stable. Thanks.

> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>   net/sched/cls_api.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index 2ee29a3..2b2a797 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -345,7 +345,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
>   			if (err == 0) {
>   				struct tcf_proto *next = rtnl_dereference(tp->next);
>
> -				tfilter_notify(net, skb, n, tp, fh,
> +				tfilter_notify(net, skb, n, tp,
> +					       t->tcm_handle,
>   					       RTM_DELTFILTER, false);
>   				if (tcf_destroy(tp, false))
>   					RCU_INIT_POINTER(*back, next);
>
