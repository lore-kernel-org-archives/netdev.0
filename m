From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 1/1] net sched actions: bug fix dumping actions
 directly didnt produce NLMSG_DONE
Date: Mon, 13 Jun 2016 15:58:53 -0700
Message-ID: <CAM_iQpUmHZBHvykV0V2u9+Bja5-NwN1=z9NqZcxkB=zAfawoDQ@mail.gmail.com>
References: <1465855722-26727-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:35647 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbcFMW7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 18:59:13 -0400
Received: by mail-yw0-f194.google.com with SMTP id v137so9755792ywa.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 15:59:12 -0700 (PDT)
In-Reply-To: <1465855722-26727-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 3:08 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> This refers to commands to direct action access as follows:
>
> sudo tc actions add action drop index 12
> sudo tc actions add action pipe index 10
>
> And then dumping them like so:
> sudo tc actions ls action gact
>
> iproute2 worked because it depended on absence of TCA_ACT_TAB TLV
> as end of message.
> This fix has been tested with iproute2 and is backward compatible.
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  net/sched/act_api.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index 336774a..c7a0b0d 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -1118,7 +1118,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
>                 nla_nest_end(skb, nest);
>                 ret = skb->len;
>         } else
> -               nla_nest_cancel(skb, nest);
> +               nlmsg_trim(skb, b);

So trim the whole tcamsg instead of just the nest attribute,
looks reasonable:

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
