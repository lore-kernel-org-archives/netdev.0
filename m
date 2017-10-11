From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/4] net: sched: make tc_action_ops->get_dev
 return dev and avoid passing net
Date: Wed, 11 Oct 2017 22:43:54 +0200
Message-ID: <20171011204354.GC9297@nanopsycho>
References: <20171010073016.3682-1-jiri@resnulli.us>
 <20171010073016.3682-2-jiri@resnulli.us>
 <CAM_iQpXjq1QVVAC2L3TdTEJzdda1=H1V=c4n5v+qeYJqCSxoWw@mail.gmail.com>
 <20171010211926.GL2033@nanopsycho>
 <CAM_iQpU5MP546FjwdD_PtOUFiAKb_TiRBEY3b+Kt9mVcCY7MTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Saeed Mahameed <saeedm@mellanox.com>, matanb@mellanox.com,
        leonro@mellanox.com, mlxsw@mellanox.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:38157 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751981AbdJKUn4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 16:43:56 -0400
Received: by mail-wm0-f65.google.com with SMTP id q124so2883421wmb.5
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 13:43:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpU5MP546FjwdD_PtOUFiAKb_TiRBEY3b+Kt9mVcCY7MTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 11, 2017 at 06:34:51PM CEST, xiyou.wangcong@gmail.com wrote:
>On Tue, Oct 10, 2017 at 2:19 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Oct 10, 2017 at 07:44:53PM CEST, xiyou.wangcong@gmail.com wrote:
>>>On Tue, Oct 10, 2017 at 12:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> -static int tcf_mirred_device(const struct tc_action *a, struct net *net,
>>>> -                            struct net_device **mirred_dev)
>>>> +static struct net_device *tcf_mirred_get_dev(const struct tc_action *a)
>>>>  {
>>>> -       int ifindex = tcf_mirred_ifindex(a);
>>>> +       struct tcf_mirred *m = to_mirred(a);
>>>>
>>>> -       *mirred_dev = __dev_get_by_index(net, ifindex);
>>>> -       if (!*mirred_dev)
>>>> -               return -EINVAL;
>>>> -       return 0;
>>>> +       return __dev_get_by_index(m->net, m->tcfm_ifindex);
>>>
>>>Hmm, why not just return m->tcfm_dev?
>>
>> I just follow the existing code. The change you suggest should be a
>> separate follow-up patch.
>
>Why?

I try to do small contained changes per patch. The resulting code is
doing the same thing as the original, therefore reducing possible bug
appearance. 

>
>Your goal is "make tc_action_ops->get_dev return dev and avoid passing net",
>using m->tcfm_dev is simpler and could save you from adding a net pointer
>to struct tcf_mirred too.
