From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Tue, 23 Sep 2008 01:06:23 -0700 (PDT)
Message-ID: <20080923.010623.193686078.davem@davemloft.net>
References: <20080921111551.GB2551@ami.dom.local>
	<20080922.221658.221283630.davem@davemloft.net>
	<20080923080240.GA4692@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52455
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750839AbYIWIGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 04:06:35 -0400
In-Reply-To: <20080923080240.GA4692@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 23 Sep 2008 08:02:40 +0000

> OK, then we have to say B and try this all. BTW, I guess, after this
> change we could have similar effect as reported by Alexander Duyck
> while testing his solution for this problem, namely the higher drop
> rate in some cases, which I can only explain as: less time in
> requeuing more time for new enqueuing. Of course, if I'm right, this
> "bug" should be rather "fixed" with longer queues or some other
> throttle mechanism.
 ...
> pkt_sched: Remove the tx queue state check in qdisc_run()
> 
> The current check wrongly uses the state of one (currently the first)
> tx queue for all tx queues in case of non-default qdiscs. This check
> mainly prevented requeuing loop with __netif_schedule(), but now it's
> controlled inside __qdisc_run(), while dequeuing. The wrongness of
> this check was first noticed by Herbert Xu.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Agreed and applied, thanks Jarek.
