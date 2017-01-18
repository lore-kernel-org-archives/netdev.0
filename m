From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: Add support for user
 cookies
Date: Wed, 18 Jan 2017 06:35:29 -0500
Message-ID: <43669d61-d73b-416e-95e5-24d43cdceca1@mojatatu.com>
References: <1484651509-27500-1-git-send-email-jhs@emojatatu.com>
 <1484651509-27500-2-git-send-email-jhs@emojatatu.com>
 <CAM_iQpUfvSCJ6j+GsefShWK++tfuBr=buWauBY81gaOpqvN=gA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36599 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbdARLn5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 06:43:57 -0500
Received: by mail-qt0-f195.google.com with SMTP id l7so1224493qtd.3
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 03:43:57 -0800 (PST)
In-Reply-To: <CAM_iQpUfvSCJ6j+GsefShWK++tfuBr=buWauBY81gaOpqvN=gA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-17 01:40 PM, Cong Wang wrote:
> On Tue, Jan 17, 2017 at 3:11 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> @@ -575,6 +583,23 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
>>         if (err < 0)
>>                 goto err_mod;
>>
>> +       if (tb[TCA_ACT_COOKIE]) {
>> +               if (nla_len(tb[TCA_ACT_COOKIE]) > TC_COOKIE_MAX_SIZE) {
>> +                       err = -EINVAL;
>> +                       goto err_mod;
>> +               }
>> +
>> +               a->act_ck = kzalloc(sizeof(*a->act_ck), GFP_KERNEL);
>> +               if (unlikely(!a->act_ck)) {
>> +                       err = -ENOMEM;
>> +                       goto err_mod;
>> +               }
>> +
>
> I am afraid you can't just goto err_mod for error case here, b/c ->init()
> is already called before this, you probably either have to call ->destroy()
> for error path, or move this before ->init().
>

Thanks for catching this. Deserves a respin.
Easier to move it earlier.

cheers,
jamal
