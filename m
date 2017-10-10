From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/4] net: sched: make tc_action_ops->get_dev
 return dev and avoid passing net
Date: Tue, 10 Oct 2017 23:19:26 +0200
Message-ID: <20171010211926.GL2033@nanopsycho>
References: <20171010073016.3682-1-jiri@resnulli.us>
 <20171010073016.3682-2-jiri@resnulli.us>
 <CAM_iQpXjq1QVVAC2L3TdTEJzdda1=H1V=c4n5v+qeYJqCSxoWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Saeed Mahameed <saeedm@mellanox.com>, matanb@mellanox.com,
        leonro@mellanox.com, mlxsw@mellanox.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:54986 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932608AbdJJVT2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 17:19:28 -0400
Received: by mail-wm0-f66.google.com with SMTP id i124so666034wmf.3
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 14:19:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpXjq1QVVAC2L3TdTEJzdda1=H1V=c4n5v+qeYJqCSxoWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 10, 2017 at 07:44:53PM CEST, xiyou.wangcong@gmail.com wrote:
>On Tue, Oct 10, 2017 at 12:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> -static int tcf_mirred_device(const struct tc_action *a, struct net *net,
>> -                            struct net_device **mirred_dev)
>> +static struct net_device *tcf_mirred_get_dev(const struct tc_action *a)
>>  {
>> -       int ifindex = tcf_mirred_ifindex(a);
>> +       struct tcf_mirred *m = to_mirred(a);
>>
>> -       *mirred_dev = __dev_get_by_index(net, ifindex);
>> -       if (!*mirred_dev)
>> -               return -EINVAL;
>> -       return 0;
>> +       return __dev_get_by_index(m->net, m->tcfm_ifindex);
>
>Hmm, why not just return m->tcfm_dev?

I just follow the existing code. The change you suggest should be a
separate follow-up patch.
