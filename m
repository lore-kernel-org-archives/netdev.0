From: Phil Sutter <phil@nwl.cc>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Thu, 14 Apr 2016 17:18:13 +0200
Message-ID: <20160414151813.GE3715@orbyte.nwl.cc>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
 <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Kosina <jikos@kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36076 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756397AbcDNPSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2016 11:18:16 -0400
Content-Disposition: inline
In-Reply-To: <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 14, 2016 at 08:01:39AM -0700, Eric Dumazet wrote:
> On Thu, 2016-04-14 at 16:44 +0200, Jiri Kosina wrote:
> > Hi,
> > 
> > I've came across the behavior where adding a child qdisc and then deleting 
> > it again makes the networking dysfunctional (I guess that's because all of 
> > a sudden there is absolutely no working qdisc on the device, although 
> > there originally was a default one in the parent).
> > 
> > In a nutshell, is this expected behavior or bug?
> 
> This is the expected behavior.

OTOH some qdiscs (CBQ, DRR, DSMARK, HFSC, HTB, QFQ) assign the default
one upon deletion instead of noop_qdisc, hence I would describe
the situation using the words 'inconsistent' and 'accident' rather than
'expected'. :)

Anyhow, the problem with skilled admins is they accept quirks too easily
and just build their scripts around them - the same scripts we have to
keep compatible to then.

Cheers, Phil
