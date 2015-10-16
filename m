From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 1/4] net_sched: introduce qdisc_replace() helper
Date: Fri, 16 Oct 2015 07:51:45 -0400
Message-ID: <5620E4D1.60403@mojatatu.com>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
 <1444675083-9825-2-git-send-email-xiyou.wangcong@gmail.com>
 <561E42DC.2080502@mojatatu.com>
 <CAM_iQpXyjg+d7idQBfmwX7PQgC5upaTC9327wPjMFVNNn=EAkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35515 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbbJPLvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 07:51:48 -0400
Received: by iofl186 with SMTP id l186so121156976iof.2
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 04:51:47 -0700 (PDT)
In-Reply-To: <CAM_iQpXyjg+d7idQBfmwX7PQgC5upaTC9327wPjMFVNNn=EAkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/15 00:15, Cong Wang wrote:
> On Wed, Oct 14, 2015 at 4:56 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 10/12/15 14:38, Cong Wang wrote:
>>>
>>> Remove nearly duplicated code and prepare for the following patch.
>>>
>>
>>
>> Cong - like Dave, I dont see equivalence in some of these
>> changes.
>> Example not sure how the qfq grafting invocation of
>> qfq_purge_queue fits in. There are a few others.
>
> drr_purge_queue() and qfq_purge_queue() are both
> qdisc_reset() + qdisc_tree_decrease_qlen():
>
>
> static void drr_purge_queue(struct drr_class *cl)
> {
>          unsigned int len = cl->qdisc->q.qlen;
>
>          qdisc_reset(cl->qdisc);
>          qdisc_tree_decrease_qlen(cl->qdisc, len);
> }
>
> static void qfq_purge_queue(struct qfq_class *cl)
> {
>          unsigned int len = cl->qdisc->q.qlen;
>
>          qdisc_reset(cl->qdisc);
>          qdisc_tree_decrease_qlen(cl->qdisc, len);
> }
>
> Or you mean the order of calling them??
>

I dont think the order is as important (although the way you have
it seems to be the sanest).

Thanks for clarifying Cong. I took a closer look and
all looks good.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
