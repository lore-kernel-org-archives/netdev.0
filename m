From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 2/4] net_sched: update hierarchical backlog too
Date: Fri, 16 Oct 2015 08:22:15 -0400
Message-ID: <5620EBF7.6080602@mojatatu.com>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
 <1444675083-9825-3-git-send-email-xiyou.wangcong@gmail.com>
 <561E4663.4080101@mojatatu.com>
 <CAM_iQpWmxhY9Y9PU+9kYYvoc2C07aTxMPxSny1pW+cVYu4TqGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:33706 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753797AbbJPMWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:22:18 -0400
Received: by igbkq10 with SMTP id kq10so12521778igb.0
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:22:17 -0700 (PDT)
In-Reply-To: <CAM_iQpWmxhY9Y9PU+9kYYvoc2C07aTxMPxSny1pW+cVYu4TqGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/15 00:32, Cong Wang wrote:
> On Wed, Oct 14, 2015 at 5:11 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 10/12/15 14:38, Cong Wang wrote:
>>>
>>> When the bottom qdisc decides to, for example, drop some packet,
>>> it calls qdisc_tree_decrease_qlen() to update the queue length
>>> for all its ancestors, we need to update the backlog too to
>>> keep the stats on root qdisc accurate.
>>>
>>
>>
>> There is more than one change in there (the codel change seems
>> out of place and i wasnt sure why it was needed).
>
> I thought it is clear that when codel decides to drop some packets
> we don't know how many bytes it drops, we only know how many
> packets before my patch. For example,
>
> -               qdisc_tree_decrease_qlen(sch, q->cstats.drop_count);
> +               qdisc_tree_reduce_backlog(sch, q->cstats.drop_count,
> +                                         q->cstats.drop_len);
>
> This clearly means I need some codel stats from codel to pass to
> qdisc_tree_reduce_backlog(), this is  why the codel part is
> necessary.
>
>
>> Also it seems possible you are double-dipping in some cases;
>> i dont have time to scrutinize - but looking at codel_change() change
>> when the queue limit is exceeded you will end up affecting backlog from
>> both qdisc_qstats_backlog_dec() and your new
>> qdisc_tree_reduce_backlog()
>
> Nope, qdisc_qstats_backlog_dec() decreases the backlog of itself,
> qdisc_tree_reduce_backlog() decreases its upper qdiscs'. It is correct
> as it was.
>

Didnt look closer - will take your word for it.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
