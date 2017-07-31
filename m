From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next 04/20] net: sched: use tcf_exts_has_actions in tcf_exts_exec
Date: Mon, 31 Jul 2017 13:37:21 -0700
Message-ID: <CAM_iQpWRo1HG8WpZ-0zNferBe44yFpwoLpNWn5CKv9YuD9TKBQ@mail.gmail.com>
References: <20170728144042.6380-1-jiri@resnulli.us> <20170728144042.6380-5-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Daniel Borkmann <daniel@iogearbox.net>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35311 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751046AbdGaUhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 16:37:43 -0400
Received: by mail-wm0-f66.google.com with SMTP id r77so225331wmd.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 13:37:42 -0700 (PDT)
In-Reply-To: <20170728144042.6380-5-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 7:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> +static inline int
> +tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
> +             struct tcf_result *res)
> +{
> +#ifdef CONFIG_NET_CLS_ACT
> +       if (tcf_exts_has_actions(exts))
> +               return tcf_action_exec(skb, exts->actions, exts->nr_actions,
> +                                      res);
> +#endif
> +       return 0;
> +}


While you are on it, can we get rid of this macro too?

tcf_action_exec() is only defined with CONFIG_NET_CLS_ACT,
not sure if compiler is kind enough to eliminate the false branch
for us:

if (false)
    return tcf_action_exec(...); // not defined but the branch is dead

At least you can add a wrapper for tcf_action_exec() to just
return 0.
