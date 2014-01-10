From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC Patch net-next 4/4] net_sched: make ingress qdisc lockless
Date: Thu, 09 Jan 2014 17:11:23 -0800
Message-ID: <1389316283.31367.79.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1389291593-2494-5-git-send-email-xiyou.wangcong@gmail.com>
	 <1389313313.31367.74.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpUj9kg=15K3yyOWuMEaxWQC2TUStAMjHrn+ixbGyYHK0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:59132 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbaAJBL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 20:11:26 -0500
Received: by mail-yh0-f51.google.com with SMTP id l109so440943yhq.38
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 17:11:26 -0800 (PST)
In-Reply-To: <CAM_iQpUj9kg=15K3yyOWuMEaxWQC2TUStAMjHrn+ixbGyYHK0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 16:30 -0800, Cong Wang wrote:
> On Thu, Jan 9, 2014 at 4:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> >
> > Really, you'll have to explain in the changelog why you think this is
> > safe, because I really do not see how this can be valid.
> >
> > I think I already said it was not safe at all...
> >
> > You could try a multiqueue NIC for some interesting effects.
> >
> 
> There is only one ingress queue, that is dev->ingress_queue, right ?

Yes. And you can have multiple cpus trying to use it at the same time.

> And since on ingress, the only possible qdisc is sch_ingress,
> looking at ingress_enqueue(), I don't see anything so dangerous.
> 
> As I said in the cover letter, I may still miss something in the qdisc
> layer, but doesn't look like related with multiqueue. Mind to be more
> specific?

Well, there is one qdisc, and if your NIC is multiqueue, with for
example 32 queues, you can have 32 cpu happily using this qdisc at once.

Thats why you need the spinlock.

I am very afraid seeing you changing this path without understanding
how it is used.
