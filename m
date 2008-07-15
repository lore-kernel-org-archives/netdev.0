From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v4 2/2] hfsc: add link layer overhead
 adaption
Date: Mon, 14 Jul 2008 22:11:25 -0700 (PDT)
Message-ID: <20080714.221125.137630059.davem@davemloft.net>
References: <20080710193434.19525.83454.stgit@fate.lan>
	<20080710193440.19525.93085.stgit@fate.lan>
	<487B61A9.5090204@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49006
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753197AbYGOFLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:11:25 -0400
In-Reply-To: <487B61A9.5090204@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 14 Jul 2008 16:24:41 +0200

> I thought you were going to make this a generic qdisc feature.
> Why is configuration still qdisc specific?
> 
> I was thinking of something like this:
> 
> - add generic attributes for configuring size tables for any
>    qdisc, handle those in sch_api
> 
> - add qdisc_enqueue() wrapper that calculates the size and
>    stores it in skb->cb, convert direct calls of sch->enqueue
>    to use it
> 
> - change direct uses of skb->len to use the size from the cb
> 
> The second step might need a bit more thought to make sure
> qdiscs don't get confused when the dequeued packet is larger
> than the enqueued one, but I think they usually don't care.

This sounds sane.

After having to edit every damn file net/sched/ over the weekend
a few things really bugged me.  One of which was how so much logic
is duplicated in the configuration support code.

The worst offender is TCA_RATE, it's scattered all over the place.

If I get ambitious after all the multiqueue bits are sorted I might
try to consolidate some of this stuff.

But definitely, let's not add more of that kind of stuff.
