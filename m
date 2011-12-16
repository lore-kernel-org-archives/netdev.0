From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 09:19:23 -0800
Message-ID: <20111216091923.6ff3cbc2@s6510.linuxnetplumber.net>
References: <igorm@etf.rs>
	<1324049163-11207-1-git-send-email-igorm@etf.rs>
	<1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAFdo_mWY3030_WsL_awXFMaviMA5MGJP_gMs0cM=6KeGQft6-Q@mail.gmail.com>
	<1324053184.25554.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1112161043080.26765@router.home>
	<1324054244.25554.56.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1112161053030.26765@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, igorm@etf.rs,
	netdev@vger.kernel.org, davem@davemloft.net
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57053 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760236Ab1LPRT0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 12:19:26 -0500
In-Reply-To: <alpine.DEB.2.00.1112161053030.26765@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Dec 2011 10:55:18 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Fri, 16 Dec 2011, Eric Dumazet wrote:
> 
> > Or we could use a hierarchical split : Say 16 (or 32 or 64) cpus share
> > same counters (must be atomic if NR_CPUS > 16/32/64)
> 
> Then you'd need to have locking or full atomic operations for the
> counters. Reduction of network processing to a set of processors also will
> have other beneficial effects in addition to cache hotness. It would
> removing OS jitter etc etc.
> 
> > percpu_alloc() -> percpugroup_alloc()
> 
> Sounds like a per cpuset/cgroup allocation?

The problem is not per cpu usage for the traffic counters at the ipv4 level. The problem is
the multiplicative growth with 10,000 interfaces and 1024 cpus! Also, IPV6
was ridiculous with keeping for per-cpu counters for things that don't matter
the ICMP counters (thanks to Eric for addressing that one. Only a few
values in the ipstats mib are really in the hot path, others seem to be handled
that way only because the code is cleaner doing it that way.
