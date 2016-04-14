From: Phil Sutter <phil@nwl.cc>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Thu, 14 Apr 2016 18:22:29 +0200
Message-ID: <20160414162229.GF3715@orbyte.nwl.cc>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
 <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160414151813.GE3715@orbyte.nwl.cc>
 <alpine.LNX.2.00.1604141733250.27368@cbobk.fhfr.pm>
 <1460648680.10638.47.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Kosina <jikos@kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54976 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753178AbcDNQWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2016 12:22:31 -0400
Content-Disposition: inline
In-Reply-To: <1460648680.10638.47.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 14, 2016 at 08:44:40AM -0700, Eric Dumazet wrote:
> On Thu, 2016-04-14 at 17:34 +0200, Jiri Kosina wrote:
> > On Thu, 14 Apr 2016, Phil Sutter wrote:
> > 
> > > OTOH some qdiscs (CBQ, DRR, DSMARK, HFSC, HTB, QFQ) assign the default
> > > one upon deletion instead of noop_qdisc, hence I would describe
> > > the situation using the words 'inconsistent' and 'accident' rather than
> > > 'expected'. :)
> > 
> > Exactly. I'd again like to stress the fact that this configuration works:
> > 
> > 	jikos:~ # tc qdisc show
> > 	qdisc tbf 10: dev eth0 root refcnt 2 rate 800Mbit burst 131000b lat 1.0ms 
> > 
> > and this (after performing add/delete operation) doesn't:
> > 
> > 	jikos:~ # tc qdisc show
> > 	qdisc tbf 10: dev eth0 root refcnt 2 rate 800Mbit burst 131000b lat 1.0ms 
> > 
> > It's hard to spot a difference (hint: there is none).
> 
> This is because some qdisc are not visible in the dump.

And those being invisible can be overridden using 'tc qd add', right?
AFAIR they're not listed because they don't properly register, so the
system doesn't care to override them. In this case we could change all
classful qdiscs to restore the default qdisc if a leaf qdisc is being
deleted instead of noop (which is probably not what the user wants
anyway).

Cheers, Phil
