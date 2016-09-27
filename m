From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2] net/sched: pkt_cls: change tc actions order
 to be as the user sets
Date: Tue, 27 Sep 2016 12:15:22 +0300
Message-ID: <CAJL1qvFE4QU9eHiPfqGjq6hufceUnN8Sth6vFaaFnNvpRHL4+w@mail.gmail.com>
References: <1474963791-3717-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35652 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932672AbcI0JPY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 05:15:24 -0400
Received: by mail-oi0-f65.google.com with SMTP id n202so490353oig.2
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 02:15:23 -0700 (PDT)
In-Reply-To: <1474963791-3717-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2016 at 11:09 AM, Hadar Hen Zion <hadarh@mellanox.com> wrote:
> Currently the created tc actions list is reversed against the order
> set by the user.
> Change the actions list order to be the same as was set by the user.
>
> This patch doesn't affect dump actions behavior.
> For dumping, action->order parameter is used so the list order doesn't
> matter.
>
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


Changes from V1:
- Add a comment to the change log


> ---
>  include/net/pkt_cls.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index 5ccaa4b..767b03a 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -123,7 +123,7 @@ static inline void tcf_exts_to_list(const struct tcf_exts *exts,
>         for (i = 0; i < exts->nr_actions; i++) {
>                 struct tc_action *a = exts->actions[i];
>
> -               list_add(&a->list, actions);
> +               list_add_tail(&a->list, actions);
>         }
>  #endif
>  }
> --
> 1.8.3.1
>
