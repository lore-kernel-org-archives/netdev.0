From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: Add support for user cookies
Date: Tue, 17 Jan 2017 10:40:31 -0800
Message-ID: <CAM_iQpUfvSCJ6j+GsefShWK++tfuBr=buWauBY81gaOpqvN=gA@mail.gmail.com>
References: <1484651509-27500-1-git-send-email-jhs@emojatatu.com> <1484651509-27500-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, paulb@mellanox.com,
        John Fastabend <john.fastabend@gmail.com>,
        Simon Horman <simon.horman@netronome.com>,
        Roman Mashak <mrv@mojatatu.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35185 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdAQSm3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 13:42:29 -0500
Received: by mail-wm0-f67.google.com with SMTP id d140so24145898wmd.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 10:40:53 -0800 (PST)
In-Reply-To: <1484651509-27500-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 3:11 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> @@ -575,6 +583,23 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
>         if (err < 0)
>                 goto err_mod;
>
> +       if (tb[TCA_ACT_COOKIE]) {
> +               if (nla_len(tb[TCA_ACT_COOKIE]) > TC_COOKIE_MAX_SIZE) {
> +                       err = -EINVAL;
> +                       goto err_mod;
> +               }
> +
> +               a->act_ck = kzalloc(sizeof(*a->act_ck), GFP_KERNEL);
> +               if (unlikely(!a->act_ck)) {
> +                       err = -ENOMEM;
> +                       goto err_mod;
> +               }
> +

I am afraid you can't just goto err_mod for error case here, b/c ->init()
is already called before this, you probably either have to call ->destroy()
for error path, or move this before ->init().
