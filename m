From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH 0/9]: tcp-2.6 patchset
Date: Sun, 27 May 2007 17:04:30 +0300
Message-ID: <20070527140430.GA30299@galon.ev-en.org>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi> <20070526.164418.115928217.davem@davemloft.net> <Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi> <20070527.021104.74747736.davem@davemloft.net> <Pine.LNX.4.64.0705271319310.2663@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:53593
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774AbXE0OEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 10:04:31 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705271319310.2663@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi> [070527 14:16]:
> On Sun, 27 May 2007, David Miller wrote:
> 
> > From: "Ilpo_J?rvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Sun, 27 May 2007 10:58:27 +0300 (EEST)
> > 
> > > While you're in the right context (reviewing patch 8), you could also
> > > look if tcp_clean_rtx_queue does a right thing when passing a strange 
> > > pkts_acked to congestion control modules. I wonder if it really should 
> > > ignore GSO the way it does currently... I read some cc module code and 
> > > some was adding it to snd_cwnd_cnt, etc. which is a strong indication 
> > > that GSO should be considered... Also if the head is GSO skb that is not 
> > > completely acked, the loop breaks with pkts_acked being zero, I doubt
> > > that can be correct... 
> > 
> > [...snip...]
> > will likely take a look at these issues wrt. patch 8 tomorrow.
> 
> [...snip...]
> 
> Thus, my original question basically culminates in this: should cc
> modules be passed number of packets acked or number of skbs acked?
> ...The latter makes no sense to me unless the value is intented to
> be interpreted as number of timestamps acked or something along those 
> lines. ...I briefly tried looking up for documentation for cc module 
> interface but didn't find anything useful about this, and thus asked in 
> the first place...

At least the htcp module that I wrote assumes that the number is actual
number of tcp packets so GSO should be considered.

The consequences of this bug are not too large but it does make all
congestion control algorithms a lot less aggressive. On my machines GSO
is disabled by default (e1000 at 100mbps & Tigon3 @ 1Gbps).

Cheers,
Baruch
