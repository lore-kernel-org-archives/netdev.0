From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next 1/4] net: sched: make tc_action_ops->get_dev
 return dev and avoid passing net
Date: Wed, 11 Oct 2017 09:34:51 -0700
Message-ID: <CAM_iQpU5MP546FjwdD_PtOUFiAKb_TiRBEY3b+Kt9mVcCY7MTQ@mail.gmail.com>
References: <20171010073016.3682-1-jiri@resnulli.us> <20171010073016.3682-2-jiri@resnulli.us>
 <CAM_iQpXjq1QVVAC2L3TdTEJzdda1=H1V=c4n5v+qeYJqCSxoWw@mail.gmail.com> <20171010211926.GL2033@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Saeed Mahameed <saeedm@mellanox.com>, matanb@mellanox.com,
        leonro@mellanox.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:38761 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751852AbdJKQfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 12:35:12 -0400
Received: by mail-pg0-f68.google.com with SMTP id j3so2525134pga.5
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 09:35:12 -0700 (PDT)
In-Reply-To: <20171010211926.GL2033@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 2:19 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Oct 10, 2017 at 07:44:53PM CEST, xiyou.wangcong@gmail.com wrote:
>>On Tue, Oct 10, 2017 at 12:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> -static int tcf_mirred_device(const struct tc_action *a, struct net *net,
>>> -                            struct net_device **mirred_dev)
>>> +static struct net_device *tcf_mirred_get_dev(const struct tc_action *a)
>>>  {
>>> -       int ifindex = tcf_mirred_ifindex(a);
>>> +       struct tcf_mirred *m = to_mirred(a);
>>>
>>> -       *mirred_dev = __dev_get_by_index(net, ifindex);
>>> -       if (!*mirred_dev)
>>> -               return -EINVAL;
>>> -       return 0;
>>> +       return __dev_get_by_index(m->net, m->tcfm_ifindex);
>>
>>Hmm, why not just return m->tcfm_dev?
>
> I just follow the existing code. The change you suggest should be a
> separate follow-up patch.

Why?

Your goal is "make tc_action_ops->get_dev return dev and avoid passing net",
using m->tcfm_dev is simpler and could save you from adding a net pointer
to struct tcf_mirred too.
