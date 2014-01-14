From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 0/5] Assorted mvneta fixes
Date: Tue, 14 Jan 2014 08:24:53 +0100
Message-ID: <20140114072453.GC27536@1wt.eu>
References: <1389519069-1619-1-git-send-email-w@1wt.eu> <87ob3hovkf.fsf@natisbad.org> <20140112222233.GG16576@1wt.eu> <87d2jvfr1m.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55346 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642AbaANHZC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 02:25:02 -0500
Content-Disposition: inline
In-Reply-To: <87d2jvfr1m.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnaud,

On Mon, Jan 13, 2014 at 11:36:05PM +0100, Arnaud Ebalard wrote:
> Hi,
> 
> Willy Tarreau <w@1wt.eu> writes:
> 
> >> Funny enough, I spent some time this week-end trying to find the root
> >> cause of some kernel freezes and panics appearing randomly after some GB
> >> read on a ReadyNAS 102 configured as a NFS server. 
> >> 
> >> I tested your fixes and performance series together on top of current
> >> 3.13.0-rc7 and I am now unable to reproduce the freeze and panics after
> >> having read more than the 300GB of traffic from the NAS: following
> >> bandwith with a bwm-ng shows the rate is also far more stable than w/
> >> previous driver logic (55MB/sec). So, FWIW:
> >> 
> >> Tested-by: Arnaud Ebalard <arno@natisbad.org>
> >
> > Thanks for this.
> >
> > BTW, the "performance" series is not supposed to fix anything, 
> 
> I was lazy and wanted to give the whole set a try in a single pass.
> 
> 
> > and still it seems difficult to me to find what patch might have fixed
> > your problem. Maybe the timer used in place of an IRQ has an even
> > worse effect than what we could imagine ?
> 
> I guess so.
> 
> 
> >> Willy, I can extend the test to RN2120 if you think it is useful to also
> >> do additional tests on a dual-core armada XP.
> >
> > It's up to you. These patches have run extensively on my Mirabox (Armada370),
> > OpenBlocks AX3 (ArmadaXP dual core) and the XP-GP board (ArmadaXP quad core),
> > and fixed the stability issues and performance issues I was facing there. But
> > you may be interested in testing them with your workloads (none of my boxes
> > is used as an NFS server, NAS or whatever, they mainly see HTTP and very small
> > packets used in stress tests).
> 
> Well, I spent the evening on my RN104 (Aramda370 w/ 2 GbE ifaces) and my
> RN2120 (Dual core ArmadaXP w/ 2GbE ifaces) using one as a router and
> serving NFS traffic from the other (and then changing roles). I passed
> hundreds of GB of TCP/NFS traffic and did not see any issue.
> 
> Additionally, FWIW, testing both using netperf show they easily support
> routing traffic w/ line rate perf.
> 
> Regarding the patches, the problem they solve impacts all Armada boards
> (370 and XP) which are used for network tasks. I think it would be nice
> to have those backported to stable. I can commit to do the tests of the
> backports both on XP and 370 hardware down to 3.12 or 3.11 kernel if it
> can help. 

I think so. I've been successfully using them from 3.10 and upwards.

Cheers,
Willy
