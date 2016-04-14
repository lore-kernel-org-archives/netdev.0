From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Thu, 14 Apr 2016 10:49:30 -0700
Message-ID: <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
	 <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160414151813.GE3715@orbyte.nwl.cc>
	 <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35470 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932511AbcDNRtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 13:49:33 -0400
In-Reply-To: <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-14 at 18:08 +0200, Jiri Kosina wrote:
> On Thu, 14 Apr 2016, Phil Sutter wrote:
> 
> > > > I've came across the behavior where adding a child qdisc and then deleting 
> > > > it again makes the networking dysfunctional (I guess that's because all of 
> > > > a sudden there is absolutely no working qdisc on the device, although 
> > > > there originally was a default one in the parent).
> > > > 
> > > > In a nutshell, is this expected behavior or bug?
> > > 
> > > This is the expected behavior.
> > 
> > OTOH some qdiscs (CBQ, DRR, DSMARK, HFSC, HTB, QFQ) assign the default
> > one upon deletion instead of noop_qdisc, hence I would describe
> > the situation using the words 'inconsistent' and 'accident' rather than
> > 'expected'. :)
> 
> Would a patch that'd unify this in a sense that all qdiscs would assign 
> the default one upon deletion acceptable?
> 

And what would be the chosen behavior ?

Relying on TBF installing a bfifo for you at delete would be hazardous.

For example CBQ got it differently than HFSC

If qdisc_create_dflt() fails in CBQ, we fail the 'delete', while HFSC
falls back to noop_qdisc, without warning the user :(

At least always using noop_qdisc is consistent. No magic there.

Doing 'unification' right now would break existing scripts.

This is too late, I am afraid.
