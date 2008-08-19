From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Tue, 19 Aug 2008 06:59:58 +0000
Message-ID: <20080819065958.GB4376@ff.dom.local>
References: <200808181404.56131.denys@visp.net.lb> <20080818112022.GA7158@ff.dom.local> <20080818113531.GB7158@ff.dom.local> <20080818.205427.140031432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:52352 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbYHSHAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 03:00:03 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1367527nfc.21
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 00:00:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080818.205427.140031432.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 08:54:27PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 18 Aug 2008 11:35:31 +0000
> 
> > pkt_sched: Add lockdep annotation for qdisc locks
> > 
> > Qdisc locks are initialized in the same function, qdisc_alloc(), so
> > lockdep can't distinguish tx qdisc lock from rx and reports "possible
> > recursive locking detected" when both these locks are taken eg. while
> > using act_mirred with ifb. This looks like a false positive. Anyway,
> > after this patch these locks will be reported more exactly.
> > 
> > Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Applied, thanks Jarek.
> 
> I suspect we need to apply this lock annotation to the locks
> in the static qdiscs &noop_qdisc and &noqueue_qdisc.
> 

I guess, we currently don't need this. At least ingress checks and
skipps acting for &noop_qdisc. I'd prefer to see some lockdep warning
first, or maybe you could show some scenario?

Jarek P.
