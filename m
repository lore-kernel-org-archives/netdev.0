From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: sched: fix a use-after-free error on chain on the
 error exit path
Date: Fri, 19 May 2017 10:17:59 -0700
Message-ID: <CAM_iQpX+aSOK8+K5eU1s=2LJzZgBdCvWBkhuT3ByZSqKWpSSvw@mail.gmail.com>
References: <20170518140702.6072-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33349 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750943AbdESRSV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 13:18:21 -0400
In-Reply-To: <20170518140702.6072-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 7:07 AM, Colin King <colin.king@canonical.com> wrote:
> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index 4020b8d932a1..82ebdc3fcb2e 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -511,6 +511,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
>         if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
>                 tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
>                 tcf_chain_destroy(chain);


Jiri, how does this work...? An action could hold a refcnt to a filter
chain, but here you destroy a whole chain without respecting
the refcnt???


> +               chain = NULL;
>                 err = 0;
>                 goto errout;

Colin, not your fault, I think we may miss something more serious
when reviewing Jiri's patchset. ;)

Thanks.
