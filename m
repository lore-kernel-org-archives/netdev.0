From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: use per cpu variables for stats
 accounting
Date: Thu, 14 Apr 2016 22:56:17 -0400 (EDT)
Message-ID: <20160414.225617.2128747969495613941.davem@davemloft.net>
References: <597a2e5c2f664d48d3e4aac2f7d43e61940d4037.1460537477.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, hannes@stressinduktion.org,
	ebiederm@xmission.com, gkurz@linux.vnet.ibm.com,
	jasowang@redhat.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbcDOC4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 22:56:22 -0400
In-Reply-To: <597a2e5c2f664d48d3e4aac2f7d43e61940d4037.1460537477.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 13 Apr 2016 10:52:20 +0200

> Currently the tun device accounting uses dev->stats without applying any
> kind of protection, regardless that accounting happens in preemptible
> process context.
> This patch move the tun stats to a per cpu data structure, and protect
> the updates with  u64_stats_update_begin()/u64_stats_update_end() or
> this_cpu_inc according to the stat type. The per cpu stats are
> aggregated by the newly added ndo_get_stats64 ops.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Ok this seems reasonable, applied, thanks.

I guess most applications use tuntap by having two threads, one
for transmit and one for receive processing?
