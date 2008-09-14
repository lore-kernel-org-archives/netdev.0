From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Sun, 14 Sep 2008 22:27:15 +0200
Message-ID: <20080914202715.GA2540@ami.dom.local>
References: <20080913011018.GA10242@gondor.apana.org.au> <20080912.182259.238925690.davem@davemloft.net> <20080913012758.GA10459@gondor.apana.org.au> <20080912.184008.74354363.davem@davemloft.net> <20080913014800.GA10611@gondor.apana.org.au> <20080913205408.GA2545@ami.dom.local> <20080914061610.GA20571@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:51754 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736AbYINU01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 16:26:27 -0400
Received: by gxk9 with SMTP id 9so23081175gxk.13
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2008 13:26:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080914061610.GA20571@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 13, 2008 at 11:16:10PM -0700, Herbert Xu wrote:
> On Sat, Sep 13, 2008 at 10:54:08PM +0200, Jarek Poplawski wrote:
> >
> > If I get it right peek + dequeue should do all current dequeue logic
> > plus additionally write down the child qdisc or skb (leaves) info,
> > plus, probably, some ifs btw., which looks like a bit of overhead,
> > if we consider requeuing as something exceptional. Unless we don't -
> > then of course something like this could be useful.
> 
> I don't see the overhead in writing down something that we alrady
> have.  In any case, do you have an alternative solution to the
> current problem that qdisc_run looks at an arbitrary queue's
> status to decide whether it should process a qdisc that empties
> into n queues?

If it's only for this initial check I still think my earlier proposal
should be enough:
http://marc.info/?l=linux-netdev&m=122113717013988&w=2

Anyway, the main problem here was a high cpu load despite stopped
queue. Are you sure this peek, which is almost full dequeue, can
really help for this? BTW, since after current fix there were no
later complains I guess it's just about full netif_stop or non-mq
device.

Cheers,
Jarek P.
