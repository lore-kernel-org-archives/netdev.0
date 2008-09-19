From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [RFC PATCH] sched: only dequeue if packet can be queued to
	hardware queue.
Date: Fri, 19 Sep 2008 14:43:27 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F1598EDAC@orsmsx501.amr.corp.intel.com>
References: <20080918063036.27934.91273.stgit@localhost.localdomain>
 <20080918194419.GA2982@ami.dom.local> <20080919151632.GB2646@ami.dom.local>
 <80769D7B14936844A23C0C43D9FBCF0F1598E4A3@orsmsx501.amr.corp.intel.com>
 <20080919173523.GA2888@ami.dom.local>
 <80769D7B14936844A23C0C43D9FBCF0F1598E7E1@orsmsx501.amr.corp.intel.com>
 <20080919185150.GB2888@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30103 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751023AbYISVnd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 17:43:33 -0400
In-Reply-To: <20080919185150.GB2888@ami.dom.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Fri, Sep 19, 2008 at 11:01:12AM -0700, Duyck, Alexander H wrote:
> I'm not sure I understand your point. No qdisc will use any new
> q->requeue. All qdisc do dequeue, but on tx fail an skb isn't requeued
> back, but queued by qdisc_restart() in a private list (of root qdisc),
> and then tried before any new dequeuing. There will be no cpu hit,
> because each next try is only skb_peek() on this list, until tx queue
> of an skb at the head is working.

It was me missing a piece.  I didn't look over the portion where Dave
changed requeue to always use the requeue list.  This breaks multiq
and we are right back to the head-of-line blocking.  Also I think patch
1 will break things since queueing a packet with skb->next already set
will cause issues since the queue uses prev and next last I knew.

> Alas this testing is both the weekest (I'm not going to do this), and
> the strongest side of this solution, because it's mostly David's work
> (my patch could be actually skipped without much impact). So, I hope,
> you don't suggest this could be not enough tested or otherwise not the
> best?!
>
> Anyway, I don't insist on "my" solution. I simply think it's
> reasonable, and it's not for private reasons, because I didn't even
> find this out. I think, if it's so wrong you should have no problem
> to show this in one little test. And maybe David changed his mind in
> the meantime and he will choose your way even without this.

I didn't mean to insist on this if it is how it came across.  My main
concern is that I just don't want to break what I just got working.
Most of this requeue to q->requeue stuff will break multiq and
introduce head-of-line blocking.  When That happens it will fall back
into my lap to try to resolve it so that is why I want to avoid it in
the first place.

Anyway I'm out for the next two weeks with at least the first week of
that being without email access.  I hope I provided some valuable
input so that this can head in the right direction.

Thanks,

Alex



