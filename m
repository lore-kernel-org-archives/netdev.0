From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 1/1] net sched qdisc: pass netlink message flags
 in event notification
Date: Fri, 27 Oct 2017 14:55:05 -0700
Message-ID: <CAM_iQpWC=JJDBnxPTmkSjqhBGqQakoWbTuBxnLSETHo7+mQvcA@mail.gmail.com>
References: <1509054014-23254-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:45388 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932190AbdJ0Vz0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 17:55:26 -0400
Received: by mail-pg0-f66.google.com with SMTP id b192so6240727pga.2
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 14:55:26 -0700 (PDT)
In-Reply-To: <1509054014-23254-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 2:40 PM, Roman Mashak <mrv@mojatatu.com> wrote:
> Userland client should be able to read an event, and reflect it back to
> the kernel, therefore it needs to extract complete set of netlink flags.
>
> For example, this will allow "tc monitor" to distinguish Add and Replace
> qdisc operations.
>
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> ---
>  net/sched/sch_api.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index a9ac912..e3e29be 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -859,7 +859,7 @@ static int qdisc_notify(struct net *net, struct sk_buff *oskb,
>         }
>         if (new && !tc_qdisc_dump_ignore(new, false)) {
>                 if (tc_fill_qdisc(skb, new, clid, portid, n->nlmsg_seq,
> -                                 old ? NLM_F_REPLACE : 0, RTM_NEWQDISC) < 0)
> +                                 n->nlmsg_flags, RTM_NEWQDISC) < 0)


Don't you want to change the other tc_fill_qdisc() in the same function
too? ;)
