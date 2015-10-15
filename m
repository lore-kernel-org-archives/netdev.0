From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 1/4] net_sched: introduce qdisc_replace() helper
Date: Wed, 14 Oct 2015 21:15:31 -0700
Message-ID: <CAM_iQpXyjg+d7idQBfmwX7PQgC5upaTC9327wPjMFVNNn=EAkQ@mail.gmail.com>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
	<1444675083-9825-2-git-send-email-xiyou.wangcong@gmail.com>
	<561E42DC.2080502@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:35441 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbbJOEPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 00:15:32 -0400
Received: by oixx6 with SMTP id x6so23797020oix.2
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 21:15:31 -0700 (PDT)
In-Reply-To: <561E42DC.2080502@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 4:56 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 10/12/15 14:38, Cong Wang wrote:
>>
>> Remove nearly duplicated code and prepare for the following patch.
>>
>
>
> Cong - like Dave, I dont see equivalence in some of these
> changes.
> Example not sure how the qfq grafting invocation of
> qfq_purge_queue fits in. There are a few others.

drr_purge_queue() and qfq_purge_queue() are both
qdisc_reset() + qdisc_tree_decrease_qlen():


static void drr_purge_queue(struct drr_class *cl)
{
        unsigned int len = cl->qdisc->q.qlen;

        qdisc_reset(cl->qdisc);
        qdisc_tree_decrease_qlen(cl->qdisc, len);
}

static void qfq_purge_queue(struct qfq_class *cl)
{
        unsigned int len = cl->qdisc->q.qlen;

        qdisc_reset(cl->qdisc);
        qdisc_tree_decrease_qlen(cl->qdisc, len);
}

Or you mean the order of calling them??
