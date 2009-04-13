From: Martin Josefsson <gandalf@mjufs.se>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU
Date: Mon, 13 Apr 2009 21:06:10 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0904132102030.10428@wlug.westbo.se>
References: <20090411174801.GG6822@linux.vnet.ibm.com>
 <18913.53699.544083.320542@cargo.ozlabs.ibm.com> <20090412173108.GO6822@linux.vnet.ibm.com>
 <20090412.181330.23529546.davem@davemloft.net> <20090413040413.GQ6822@linux.vnet.ibm.com>
 <20090413095309.631cf395@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	paulus@samba.org, mingo@elte.hu, torvalds@linux-foundation.org,
	laijs@cn.fujitsu.com, jeff.chua.linux@gmail.com,
	dada1@cosmosbay.com, jengelh@medozas.de, kaber@trash.net,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host91-201.netintact.se ([194.153.91.201]:35167 "EHLO
	wlug.westbo.se" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbZDMTGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 15:06:17 -0400
In-Reply-To: <20090413095309.631cf395@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Apr 2009, Stephen Hemminger wrote:

> This is an alternative version of ip/ip6/arp tables locking using
> per-cpu locks.  This avoids the overhead of synchronize_net() during
> update but still removes the expensive rwlock in earlier versions.
>
> The idea for this came from an earlier version done by Eric Duzamet.
> Locking is done per-cpu, the fast path locks on the current cpu
> and updates counters.  The slow case involves acquiring the locks on
> all cpu's.

Doesn't spin_lock() result in a pipeline flush on x86?

iirc there was a benchmark in an RCU paper that tested using per cpu 
spin_locks and the result was that it didn't scale well at all.

/Martin
