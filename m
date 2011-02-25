From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Fri, 25 Feb 2011 17:48:46 -0500
Message-ID: <20110225224846.GC9763@canuck.infradead.org>
References: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
 <AANLkTi=j9VdTZjw4iTsczv2eHjTXo59-fNneBMo8rJyp@mail.gmail.com>
 <20110225125644.GA9763@canuck.infradead.org>
 <1298661495.14113.152.camel@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <therbert@google.com>,
	Bill Sommerfeld <wsommerfeld@google.com>,
	Daniel Baluta <daniel.baluta@gmail.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:43807 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523Ab1BYWsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 17:48:51 -0500
Content-Disposition: inline
In-Reply-To: <1298661495.14113.152.camel@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 11:18:15AM -0800, Rick Jones wrote:
> I think the idea is goodness, but will ask, was the (first) bottleneck
> actually in the kernel, or was it in bind itself?  I've seen
> single-instance, single-byte burst-mode netperf TCP_RR do in excess of
> 300K transactions per second (with TCP_NODELAY set) on an X5560 core.
> 
> ftp://ftp.netperf.org/netperf/misc/dl380g6_X5560_rhel54_ad386_cxgb3_1.4.1.2_b2b_to_same_agg_1500mtu_20100513-2.csv
> 
> and that was with now ancient RHEL5.4 bits...  yes, there is a bit of
> apples, oranges and kumquats but still, I am wondering if this didn't
> also "work around" some internal BIND scaling issues as well.

Yes it is. We have observed two separate bottlenecks.

The first we have discovered is within BIND. As soon as more than 1
worker thread is being used strace showed a ton of futex() system
calls to the kernel as soon as the number of queries crossed a magic
barrier. This suggested heavy lock contention within BIND.

This BIND lock contetion was not visible on all systems having scalability
issues though. Some machines were not able to deliver enough queries to
BIND in order for the lock contention to appear.
