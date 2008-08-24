From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sun, 24 Aug 2008 09:39:23 -0400
Message-ID: <1219585163.4698.43.camel@localhost>
References: <1219415417.4672.79.camel@localhost>
	 <20080822221913.GA2981@ami.dom.local>
	 <20080822.173348.232018958.davem@davemloft.net>
	 <20080823084715.GA2515@ami.dom.local>
	 <5f2db9d90808230931n453a3b75q84153dd8c18bcfc2@mail.gmail.com>
	 <1219510193.4732.26.camel@localhost>
	 <5f2db9d90808231209i134a7afbu233269c8ea592422@mail.gmail.com>
	 <20080824075331.GA2721@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:7094 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753529AbYHXNj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2008 09:39:27 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1231771rvb.1
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2008 06:39:27 -0700 (PDT)
In-Reply-To: <20080824075331.GA2721@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-24-08 at 09:53 +0200, Jarek Poplawski wrote:
> On Sat, Aug 23, 2008 at 12:09:42PM -0700, Alexander Duyck wrote:
 
> > I think you missed the email from Dave earlier, either that or I am
> > not understanding something and if I am feel free to explain.  My
> > understanding is that when we assign a new qdisc via tc the
> > qdisc/transmit queues end up with a configuration kind of like what
> > Dave has on slide 7 at
> > (http://vger.kernel.org/~davem/davem_seattle08.pdf).  Adding more
> > queues doesn't resolve anything since I am still going through the
> > same qdisc regardless of how many queues I have.  The changes to the
> > dequeue portion of this qdisc are the most important part for this
> > change since I need them to keep the qdisc from jamming up in a
> > dequeue/requeue loop if the packet at the head of the qdisc needs to
> > go to a stopped hardware transmit queue.
> 
> I guess, Jamal meant additional, backup queues, 

right; in the driver - but even that may be unnecessary.
With current controls being per qdisc instead of per netdevice,
the hol fear is unfounded. 
You send and when hw cant keep up, you block just the one hwqueue.
While hwqueue is blocked, you can accumulate packets in the prio qdisc
(hence my statement it may not be necessary to accumulate packets in
driver).
On tx completion when hwqueue has more space, you check your backup
queues; and send those first before opening up path from above. 

And to your other statement; if you use basic skb->priority to hwqueue
mapping, then you wouldnt need an extra action. 

cheers,
jamal

