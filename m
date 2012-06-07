From: Rostislav Lisovy <lisovy@gmail.com>
Subject: Re: [PATCH 2/2] net/sched: CAN Filter/Classifier
Date: Thu, 07 Jun 2012 11:53:26 +0200
Message-ID: <1339062806.4816.3.camel@lolumad>
References: <1338826176-11646-1-git-send-email-lisovy@gmail.com>
	 <1338826176-11646-2-git-send-email-lisovy@gmail.com>
	 <1338883798.2760.2043.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lartc@vger.kernel.org, pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55870 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754807Ab2FGJyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 05:54:14 -0400
In-Reply-To: <1338883798.2760.2043.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-05 at 10:09 +0200, Eric Dumazet wrote: 
> On Mon, 2012-06-04 at 18:09 +0200, Rostislav Lisovy wrote:
> > This classifier classifies CAN frames (AF_CAN) according to their
> > identifiers. This functionality can not be easily achieved with
> > existing classifiers, such as u32. This classifier can be used
> > with any available qdisc and it is able to classify both SFF
> > or EFF frames.
> > 
> > The filtering rules for EFF frames are stored in an array, which
> > is traversed during classification. A bitmap is used to store SFF
> > rules -- one bit for each ID.
> > 
> > More info about the project:
> > http://rtime.felk.cvut.cz/can/socketcan-qdisc-final.pdf
> > 
> > Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
> > ---
> >  net/sched/Kconfig   |   10 +
> >  net/sched/Makefile  |    1 +
> >  net/sched/cls_can.c |  572 +++++++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 583 insertions(+)
> >  create mode 100644 net/sched/cls_can.c
> 
> It seems a huge amount of code, and before reviewing it I would like to
> ask :
> 
> 1) Did you try to extend cls_flow somehow ?
I did not. If I understand it right, cls_flow is intended to be mainly
used with SFQ qdisc (which tries to ensure fairness among different
flows).
My intention was to make a simple and deterministic filter (which may be
used with any available qdisc).

However, after thoroughly going through cls_flow I realized that
implementing an ematch function (to be used with cls_basic or others)
will preserve the functionality and save some code at the same time.
Therefore I tend to implement a new ematch function and resubmit the
patch later if it turns to be a good approach. What do you think?

Command syntax proposed in this patch was
tc filter add ... can sffid 0x123 sffid 0x500:0x700 effid 0x00:0xff ...
An ematch could look like
tc filter add ... basic match 'canid(sff 0x123 sff 0x124:0x7f0 \
  eff 0x1234)' ...


> 2) Adding a cls_filter (or extend cls_flow to be able to use a bpf),
> could be more generic, and thanks to bpf jit could be way faster.
What do you mean with 'adding a cls_filter'?
BPF is useful only for filtering incoming data, isn't it?


> 
> 3) sfq/fq_codel could be CAN aware if you adapt skb_flow_dissect() ?
I will try to implement "deterministic ematch" filter in the first
place.
I may extend skb_flow_dissect() later.

Regards;
Rostislav Lisovy
