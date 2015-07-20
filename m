From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RGC PATCH v3.10] net: sched: validate that class is found in qdisc_tree_decrease_qlen
Date: Mon, 20 Jul 2015 11:45:12 -0700
Message-ID: <CAHA+R7OXH=niiYnku7XYe2dAdVXfZ5psKtA+dy9FdYfAvnhGZg@mail.gmail.com>
References: <1437175677-1252239-1-git-send-email-agartrell@fb.com>
	<CAHA+R7NgdD8xgi=RGcN7NjoL+p0M6vDxBPEwCjj3LZ9SWS5Yhw@mail.gmail.com>
	<CALCkm3fPck6QKRRqOUxwB18WMG8wAqGyRR+bMKPtu8mn2apbww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Gartrell <agartrell@fb.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	kernel-team <kernel-team@fb.com>
To: Alex Gartrell <alexgartrell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:35012 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836AbbGTSpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 14:45:13 -0400
Received: by ykdu72 with SMTP id u72so146065431ykd.2
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 11:45:12 -0700 (PDT)
In-Reply-To: <CALCkm3fPck6QKRRqOUxwB18WMG8wAqGyRR+bMKPtu8mn2apbww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2015 at 5:27 PM, Alex Gartrell <alexgartrell@gmail.com> wrote:
> On Fri, Jul 17, 2015 at 5:10 PM, Cong Wang <cwang@twopensource.com> wrote:
>> Hmm, but in htb_delete() we do reset the leaf qdisc before removing the
>> class from ha
>>
>>         if (!cl->level) {
>>                 qlen = cl->un.leaf.q->q.qlen;
>>                 qdisc_reset(cl->un.leaf.q);
>>                 qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
>>         }
>>
>> therefore, the leaf fq_codel qdisc is supposed to have 0 skb after that,
>> that is, the second fq_codel_reset() is supposed to return NULL immediately?
>> Why is qdidsc_tree_decrease_qlen() called in the second fq_codel_reset()?
>>
>> Or there is a race condition between ->delete() and ->put()? In which new
>> skb can be enqueued?
>
> This makes the most sense to me, but I have ~32 hours of experience
> with this subsystem :)
>
> Taking that for granted, it seems like it'd be appropriate to note the
> invariant in the code i've changed with a WARN_ON and to skip it, and
> then to otherwise find a way to close the hole.  Do you agree?
>

Your patch _does_ make sense for me, I was just trying to check
if there is any better way to fix it. :)

I was thinking about locking the qdisc tree before ->get(), but it is not
easy and may not worth the effort either. So, unless others have a
better idea here, I think your patch is fine, just please update the
changelog and rebase it against latest -net tree.

Thanks!
