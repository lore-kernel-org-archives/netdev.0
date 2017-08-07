From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 1/2] net_sched: refactor notification code for RTM_DELTFILTER
Date: Mon, 7 Aug 2017 10:50:02 -0700
Message-ID: <CAM_iQpWZV=XE=NDCVWSP2CNaYT9dgJ422ppmcUKF84FcHtZMzQ@mail.gmail.com>
References: <20170805043143.13680-1-xiyou.wangcong@gmail.com>
 <20170805043143.13680-2-xiyou.wangcong@gmail.com> <7b8c926f-8c28-b403-e380-c6ae521c9cc0@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@resnulli.us>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:36933 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdHGRuX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 13:50:23 -0400
Received: by mail-vk0-f67.google.com with SMTP id r199so542714vke.4
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 10:50:23 -0700 (PDT)
In-Reply-To: <7b8c926f-8c28-b403-e380-c6ae521c9cc0@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 6, 2017 at 4:42 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 17-08-05 12:31 AM, Cong Wang wrote:
>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>> index e655221c654e..afd099727aea 100644
>> --- a/net/sched/cls_api.c
>> +++ b/net/sched/cls_api.c
>> @@ -104,6 +104,10 @@ static int tfilter_notify(struct net *net, struct
>> sk_buff *oskb,
>>                           struct nlmsghdr *n, struct tcf_proto *tp,
>>                           unsigned long fh, int event, bool unicast);
>>   +static int tfilter_del_notify(struct net *net, struct sk_buff *oskb,
>> +                             struct nlmsghdr *n, struct tcf_proto *tp,
>> +                             unsigned long fh, bool unicast, bool *last);
>> +
>
>
> Any reason not to move the functin up here and getting rid of this
> forward declaration?

It calls tcf_fill_node() which is defined at line 643,
it is called at line 602. Moving it requires moves the
rest, this makes this patch unnecessarily bigger.
Why not make it a separate patch?
