From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Sat, 13 Sep 2008 22:54:08 +0200
Message-ID: <20080913205408.GA2545@ami.dom.local>
References: <20080913011018.GA10242@gondor.apana.org.au> <20080912.182259.238925690.davem@davemloft.net> <20080913012758.GA10459@gondor.apana.org.au> <20080912.184008.74354363.davem@davemloft.net> <20080913014800.GA10611@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:63360 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbYIMUxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2008 16:53:18 -0400
Received: by ik-out-1112.google.com with SMTP id c30so1263926ika.5
        for <netdev@vger.kernel.org>; Sat, 13 Sep 2008 13:53:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080913014800.GA10611@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2008 at 06:48:00PM -0700, Herbert Xu wrote:
> On Fri, Sep 12, 2008 at 06:40:08PM -0700, David Miller wrote:
> >
> > My current opinion is that both operations are equally difficult.
> > With the slight advantage for ->requeue() because all the complicated
> > logic is already implemented :-)
> 
> I'd agree with you if you haven't written the peek stuff :)
> 
> Now that peek exists, the dequeue stuff would be a lot simpler
> than requeue because the only non-trivial logic would be in the
> leaf qdiscs.  All the complex/classful qdiscs would be trivial
> as they'd just write down the child qdisc that was peeked and
> then call dequeue on that child.

If I get it right peek + dequeue should do all current dequeue logic
plus additionally write down the child qdisc or skb (leaves) info,
plus, probably, some ifs btw., which looks like a bit of overhead,
if we consider requeuing as something exceptional. Unless we don't -
then of course something like this could be useful.

Jarek P.
