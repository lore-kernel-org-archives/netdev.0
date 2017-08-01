From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 04/20] net: sched: use tcf_exts_has_actions in
 tcf_exts_exec
Date: Tue, 1 Aug 2017 06:53:45 +0200
Message-ID: <20170801045345.GA1939@nanopsycho>
References: <20170728144042.6380-1-jiri@resnulli.us>
 <20170728144042.6380-5-jiri@resnulli.us>
 <CAM_iQpWRo1HG8WpZ-0zNferBe44yFpwoLpNWn5CKv9YuD9TKBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Daniel Borkmann <daniel@iogearbox.net>, mlxsw@mellanox.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34400 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751012AbdHAExt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 00:53:49 -0400
Received: by mail-wm0-f65.google.com with SMTP id x64so1267081wmg.1
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 21:53:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpWRo1HG8WpZ-0zNferBe44yFpwoLpNWn5CKv9YuD9TKBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 31, 2017 at 10:37:21PM CEST, xiyou.wangcong@gmail.com wrote:
>On Fri, Jul 28, 2017 at 7:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> +static inline int
>> +tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
>> +             struct tcf_result *res)
>> +{
>> +#ifdef CONFIG_NET_CLS_ACT
>> +       if (tcf_exts_has_actions(exts))
>> +               return tcf_action_exec(skb, exts->actions, exts->nr_actions,
>> +                                      res);
>> +#endif
>> +       return 0;
>> +}
>
>
>While you are on it, can we get rid of this macro too?
>
>tcf_action_exec() is only defined with CONFIG_NET_CLS_ACT,
>not sure if compiler is kind enough to eliminate the false branch
>for us:
>
>if (false)
>    return tcf_action_exec(...); // not defined but the branch is dead
>
>At least you can add a wrapper for tcf_action_exec() to just
>return 0.

Did you see?
net: sched: remove check for number of actions in tcf_exts_exec

I will add static inline stub for tcf_action_exec in case CONFIG_NET_CLS_ACT
is not set.
