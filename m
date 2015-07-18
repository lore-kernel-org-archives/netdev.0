From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [RGC PATCH v3.10] net: sched: validate that class is found in qdisc_tree_decrease_qlen
Date: Fri, 17 Jul 2015 17:27:01 -0700
Message-ID: <CALCkm3fPck6QKRRqOUxwB18WMG8wAqGyRR+bMKPtu8mn2apbww@mail.gmail.com>
References: <1437175677-1252239-1-git-send-email-agartrell@fb.com> <CAHA+R7NgdD8xgi=RGcN7NjoL+p0M6vDxBPEwCjj3LZ9SWS5Yhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Gartrell <agartrell@fb.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	kernel-team <kernel-team@fb.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34605 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbbGRA1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 20:27:21 -0400
Received: by qkfc129 with SMTP id c129so36671858qkf.1
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 17:27:20 -0700 (PDT)
In-Reply-To: <CAHA+R7NgdD8xgi=RGcN7NjoL+p0M6vDxBPEwCjj3LZ9SWS5Yhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2015 at 5:10 PM, Cong Wang <cwang@twopensource.com> wrote:
> Hmm, but in htb_delete() we do reset the leaf qdisc before removing the
> class from ha
>
>         if (!cl->level) {
>                 qlen = cl->un.leaf.q->q.qlen;
>                 qdisc_reset(cl->un.leaf.q);
>                 qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
>         }
>
> therefore, the leaf fq_codel qdisc is supposed to have 0 skb after that,
> that is, the second fq_codel_reset() is supposed to return NULL immediately?
> Why is qdidsc_tree_decrease_qlen() called in the second fq_codel_reset()?
>
> Or there is a race condition between ->delete() and ->put()? In which new
> skb can be enqueued?

This makes the most sense to me, but I have ~32 hours of experience
with this subsystem :)

Taking that for granted, it seems like it'd be appropriate to note the
invariant in the code i've changed with a WARN_ON and to skip it, and
then to otherwise find a way to close the hole.  Do you agree?

-- 
Alex Gartrell <agartrell@fb.com>
