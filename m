From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] sch_sfq: allow big packets and be fair
Date: Tue, 21 Dec 2010 12:17:06 +0000
Message-ID: <20101221121706.GC8813@ff.dom.local>
References: <20101221101506.GA8149@ff.dom.local> <1292929037.2720.12.camel@edumazet-laptop> <20101221113920.GB8813@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:46431 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816Ab0LUMRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 07:17:14 -0500
Received: by fxm18 with SMTP id 18so4225346fxm.2
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 04:17:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101221113920.GB8813@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 21, 2010 at 11:39:20AM +0000, Jarek Poplawski wrote:
> On Tue, Dec 21, 2010 at 11:57:17AM +0100, Eric Dumazet wrote:
> > Now the check is performed at the beginning of sfq_dequeue(), to be able
> > to charge a previously sent 'big packet' multiple times (faulty flow
> > wont send a packet before passing xx rounds)
> > 
> > I believe I just did the right thing. The "allot" is incremented when
> > current flow "pass its round to next slot", and decremented when a
> > packet is dequeued from this slot. Before being allowed to dequeue a
> > packet, "allot" must be 'positive'.
> 
> Simply try to check my examples before and after. There is no skipping
> of a round now. It's a serious change. Somebody tried to avoid it at
> all in the current implementation. You should also think about fairness
> of normal (but different) size packets.

Oops! You're right yet ;-) This skipping shouldn't happen with quantum
bigger than max packet size, so this patch is OK.

Sorry,
Jarek P.
