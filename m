From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] net: sched: set xt_tgchk_param par.net properly in ipt_init_target
Date: Tue, 8 Aug 2017 12:53:17 +1200
Message-ID: <CADvbK_f+2h59SdOeGz=3bG5kBzG6GOdq_bViGqeNE_gjW26c=Q@mail.gmail.com>
References: <6252aa0d498204ec3431e9a906178fb6b1c97f00.1501922918.git.lucien.xin@gmail.com>
 <CAM_iQpWT3=kgc1Vh2BNjXSa6_n-p8+-kLhVbsaE0DzqCXMLEmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34179 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751868AbdHHAxS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 20:53:18 -0400
Received: by mail-qt0-f195.google.com with SMTP id i19so2053414qte.1
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 17:53:18 -0700 (PDT)
In-Reply-To: <CAM_iQpWT3=kgc1Vh2BNjXSa6_n-p8+-kLhVbsaE0DzqCXMLEmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 8, 2017 at 9:00 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sat, Aug 5, 2017 at 1:48 AM, Xin Long <lucien.xin@gmail.com> wrote:
>> -static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
>> +static int __tcf_ipt_init(struct net *net, struct nlattr *nla,
>>                           struct nlattr *est, struct tc_action **a,
>>                           const struct tc_action_ops *ops, int ovr, int bind)
>>  {
>> +       struct tc_action_net *tn = net_generic(net, xt_net_id);
>
> ...
>
>> @@ -193,18 +195,14 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla,
>>                         struct nlattr *est, struct tc_action **a, int ovr,
>>                         int bind)
>>  {
>> -       struct tc_action_net *tn = net_generic(net, ipt_net_id);
>> -
>> -       return __tcf_ipt_init(tn, nla, est, a, &act_ipt_ops, ovr, bind);
>> +       return __tcf_ipt_init(net, nla, est, a, &act_ipt_ops, ovr, bind);
>>  }
>>
>>  static int tcf_xt_init(struct net *net, struct nlattr *nla,
>>                        struct nlattr *est, struct tc_action **a, int ovr,
>>                        int bind)
>>  {
>> -       struct tc_action_net *tn = net_generic(net, xt_net_id);
>> -
>> -       return __tcf_ipt_init(tn, nla, est, a, &act_xt_ops, ovr, bind);
>> +       return __tcf_ipt_init(net, nla, est, a, &act_xt_ops, ovr, bind);
>
> This is not correct.
>
> You miss ipt_net_id != xt_net_id.
right, that's a silly mistake. seems no better way but to pass both
net and net_id to __tcf_ipt_init. will send v2. thanks.
