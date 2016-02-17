From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH v2 1/1] net_sched fix: reclassification needs to
 consider ether protocol changes
Date: Wed, 17 Feb 2016 09:27:06 -0800
Message-ID: <CAM_iQpX+b7F87gx4PcEhs0xFA6KtUssJAQo7+Jo9g9kLcOfB6w@mail.gmail.com>
References: <1455709055-30881-1-git-send-email-jhs@emojatatu.com>
	<1455709055-30881-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:35261 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933127AbcBQR1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 12:27:07 -0500
Received: by mail-yw0-f172.google.com with SMTP id g127so18776777ywf.2
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 09:27:06 -0800 (PST)
In-Reply-To: <1455709055-30881-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 3:37 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> actions could change the etherproto in particular with ethernet
> tunnelled data. Typically such actions, after peeling the outer header,
> will ask for the packet to be  reclassified. We then need to restart
> the classification with the new proto header.
>
> Example setup used to catch this:
> sudo tc qdisc add dev $ETH ingress
> sudo $TC filter add dev $ETH parent ffff: pref 1 protocol 802.1Q \
> u32 match u32 0 0 flowid 1:1 \
> action  vlan pop reclassify
>
> Fixes: 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}")
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  net/sched/sch_api.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index b5c2cf2..af46fee 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -1822,7 +1822,6 @@ int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  #ifdef CONFIG_NET_CLS_ACT
>         const struct tcf_proto *old_tp = tp;
>         int limit = 0;
> -

Why remove this empty line? I think it is still useful. :)

Also your patch should be targeted to -net instead of -net-next, since it
fixes a bug.

Thanks.
