From: Jiri Kosina <jikos@kernel.org>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Tue, 28 Jun 2016 17:19:13 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1606281717140.6874@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>  <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>  <20160414151813.GE3715@orbyte.nwl.cc>  <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
 <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>  <5710E1C1.2090209@mojatatu.com> <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Phil Sutter <phil@nwl.cc>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Apr 2016, Eric Dumazet wrote:

> > TBF is probably a bad example because it started life as a classless 
> > qdisc. There was only one built-in fifo queue that was shaped. Then 
> > someone made it classful and changed this behavior. To me it sounds 
> > reasonable to have the default behavior restored. At minimal 
> > consistency.
> 
> 
> Then you need to save the initial qdisc (bfifo for TBF) in a special
> place, to make sure the delete operation is guaranteed to succeed.
> 
> Or fail the delete if the bfifo can not be allocated.
> 
> I can tell that determinism if far more interesting than usability for
> some users occasionally playing with tc.

BTW, I've started to actually work on fixing this, and I've noticed that 
TBF behavior actually violates what's stated in pfifo_fast manpage:

==========
        Whenever  an  interface is created, the pfifo_fast qdisc is 
	automatically used as a queue. If another qdisc is
	attached, it preempts the default pfifo_fast, which automatically 
	returns to function when an  existing  qdisc is detached.

	In this sense this qdisc is magic, and unlike other qdiscs.
==========

-- 
Jiri Kosina
SUSE Labs
