From: Rick Jones <rick.jones2@hp.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Fri, 25 Feb 2011 15:15:00 -0800
Message-ID: <1298675700.14113.213.camel@tardy>
References: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
	 <AANLkTi=j9VdTZjw4iTsczv2eHjTXo59-fNneBMo8rJyp@mail.gmail.com>
	 <20110225125644.GA9763@canuck.infradead.org>
	 <1298661495.14113.152.camel@tardy>
	 <20110225224846.GC9763@canuck.infradead.org>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Bill Sommerfeld <wsommerfeld@google.com>,
	Daniel Baluta <daniel.baluta@gmail.com>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:22036 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523Ab1BYXPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 18:15:05 -0500
In-Reply-To: <20110225224846.GC9763@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-02-25 at 17:48 -0500, Thomas Graf wrote:
> On Fri, Feb 25, 2011 at 11:18:15AM -0800, Rick Jones wrote:
> > I think the idea is goodness, but will ask, was the (first) bottleneck
> > actually in the kernel, or was it in bind itself?  I've seen
> > single-instance, single-byte burst-mode netperf TCP_RR do in excess of
> > 300K transactions per second (with TCP_NODELAY set) on an X5560 core.
> > 
> > ftp://ftp.netperf.org/netperf/misc/dl380g6_X5560_rhel54_ad386_cxgb3_1.4.1.2_b2b_to_same_agg_1500mtu_20100513-2.csv
> > 
> > and that was with now ancient RHEL5.4 bits...  yes, there is a bit of
> > apples, oranges and kumquats but still, I am wondering if this didn't
> > also "work around" some internal BIND scaling issues as well.
> 
> Yes it is. We have observed two separate bottlenecks.
> 
> The first we have discovered is within BIND. As soon as more than 1
> worker thread is being used strace showed a ton of futex() system
> calls to the kernel as soon as the number of queries crossed a magic
> barrier. This suggested heavy lock contention within BIND.

The more things change, the more they remain the same, or perhaps "Code
may come and go, but lock contention is forever:

ftp://ftp.cup.hp.com/dist/networking/briefs/bind9_perf.txt

rick jones

The system ftp.cup.hp.com is probably going away before long, I will
probably put its collection of ancient writeups somewhere on netperf.org

> 
> This BIND lock contetion was not visible on all systems having scalability
> issues though. Some machines were not able to deliver enough queries to
> BIND in order for the lock contention to appear.


