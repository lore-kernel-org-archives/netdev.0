From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU
Date: Tue, 14 Apr 2009 14:27:34 +0200
Message-ID: <49E48136.5060700@trash.net>
References: <20090411174801.GG6822@linux.vnet.ibm.com>	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>	<20090412173108.GO6822@linux.vnet.ibm.com>	<20090412.181330.23529546.davem@davemloft.net>	<20090413040413.GQ6822@linux.vnet.ibm.com> <20090413095309.631cf395@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	paulus@samba.org, mingo@elte.hu, torvalds@linux-foundation.org,
	laijs@cn.fujitsu.com, jeff.chua.linux@gmail.com,
	dada1@cosmosbay.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62076 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbZDNM1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 08:27:45 -0400
In-Reply-To: <20090413095309.631cf395@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> This is an alternative version of ip/ip6/arp tables locking using
> per-cpu locks.  This avoids the overhead of synchronize_net() during
> update but still removes the expensive rwlock in earlier versions.
> 
> The idea for this came from an earlier version done by Eric Duzamet.
> Locking is done per-cpu, the fast path locks on the current cpu
> and updates counters.  The slow case involves acquiring the locks on
> all cpu's.
> 
> The mutex that was added for 2.6.30 in xt_table is unnecessary since
> there already is a mutex for xt[af].mutex that is held.
> 
> Tested basic functionality (add/remove/list), but don't have test cases
> for stress, ip6tables or arptables.

Thanks Stephen, I'll do some testing with ip6tables.

