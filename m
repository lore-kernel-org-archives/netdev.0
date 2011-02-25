From: Rick Jones <rick.jones2@hp.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Fri, 25 Feb 2011 11:18:15 -0800
Message-ID: <1298661495.14113.152.camel@tardy>
References: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
	 <AANLkTi=j9VdTZjw4iTsczv2eHjTXo59-fNneBMo8rJyp@mail.gmail.com>
	 <20110225125644.GA9763@canuck.infradead.org>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Bill Sommerfeld <wsommerfeld@google.com>,
	Daniel Baluta <daniel.baluta@gmail.com>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:31464 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932649Ab1BYTST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 14:18:19 -0500
In-Reply-To: <20110225125644.GA9763@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-02-25 at 07:56 -0500, Thomas Graf wrote:
> On Thu, Jan 27, 2011 at 01:32:25PM -0800, Tom Herbert wrote:
> > Yes, we are still planning this.  The UDP implementation for my
> > earlier patch should be usable to try for DNS/UDP-- this is in fact
> > where we saw a major performance gain.  Eric Dumazet had some nice
> > improvements that should probably be looked at also.
> 
> I can confirm this.
> 
> Serious scalability issues have been reported on a 12 core system
> running bind 9.7-2. The system was only able to deliver ~110K queries
> per second.
> 
> Using your SO_REUSEPORT patch and a modified bind using it. The same
> system is able to deliver ~650K queries per seconds while maxing out
> all cores completely.

I think the idea is goodness, but will ask, was the (first) bottleneck
actually in the kernel, or was it in bind itself?  I've seen
single-instance, single-byte burst-mode netperf TCP_RR do in excess of
300K transactions per second (with TCP_NODELAY set) on an X5560 core.

ftp://ftp.netperf.org/netperf/misc/dl380g6_X5560_rhel54_ad386_cxgb3_1.4.1.2_b2b_to_same_agg_1500mtu_20100513-2.csv

and that was with now ancient RHEL5.4 bits...  yes, there is a bit of
apples, oranges and kumquats but still, I am wondering if this didn't
also "work around" some internal BIND scaling issues as well.

rick jones

> 
> Tom, Bill: do you have a timeline for merging this? Especially the
> UDP bits?
> 
> -Thomas
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


