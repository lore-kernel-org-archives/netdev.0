From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC] flow : Remove an unecessary ____cacheline_aligned
Date: Tue, 01 Jan 2008 19:24:39 -0800 (PST)
Message-ID: <20080101.192439.201858398.davem@davemloft.net>
References: <477A5D4D.6000800@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57520
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753279AbYABDYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 22:24:40 -0500
In-Reply-To: <477A5D4D.6000800@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 01 Jan 2008 16:33:33 +0100

> We use a percpu variable named flow_hash_info, which holds 12 bytes.
> 
> It is currently marked as ____cacheline_aligned, which makes linker
> skip space to properly align this variable.
> 
> Before :
> c065cc90 D per_cpu__softnet_data
> c065cd00 d per_cpu__flow_tables
> <Here, hole of 124 bytes>
> c065cd80 d per_cpu__flow_hash_info
> <Here, hole of 116 bytes>
> c065ce00 d per_cpu__flow_flush_tasklets
> c065ce14 d per_cpu__rt_cache_stat
> 
> 
> This alignement is quite unproductive, and removing it reduces the
> size of percpu data (by 240 bytes on my x86 machine), and improves
> performance (flow_tables & flow_hash_info can share a single cache
> line)
> 
> After patch :
> c065cc04 D per_cpu__softnet_data
> c065cc4c d per_cpu__flow_tables
> c065cc50 d per_cpu__flow_hash_info
> c065cc5c d per_cpu__flow_flush_tasklets
> c065cc70 d per_cpu__rt_cache_stat
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Also applied, thanks a lot for these patches Eric.
