From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next 1/4] net: sched: make tc_action_ops->get_dev
 return dev and avoid passing net
Date: Tue, 10 Oct 2017 10:44:53 -0700
Message-ID: <CAM_iQpXjq1QVVAC2L3TdTEJzdda1=H1V=c4n5v+qeYJqCSxoWw@mail.gmail.com>
References: <20171010073016.3682-1-jiri@resnulli.us> <20171010073016.3682-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Saeed Mahameed <saeedm@mellanox.com>, matanb@mellanox.com,
        leonro@mellanox.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32857 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755598AbdJJRpP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 13:45:15 -0400
Received: by mail-pf0-f196.google.com with SMTP id m28so37140081pfi.0
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 10:45:14 -0700 (PDT)
In-Reply-To: <20171010073016.3682-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 12:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> -static int tcf_mirred_device(const struct tc_action *a, struct net *net,
> -                            struct net_device **mirred_dev)
> +static struct net_device *tcf_mirred_get_dev(const struct tc_action *a)
>  {
> -       int ifindex = tcf_mirred_ifindex(a);
> +       struct tcf_mirred *m = to_mirred(a);
>
> -       *mirred_dev = __dev_get_by_index(net, ifindex);
> -       if (!*mirred_dev)
> -               return -EINVAL;
> -       return 0;
> +       return __dev_get_by_index(m->net, m->tcfm_ifindex);

Hmm, why not just return m->tcfm_dev?
