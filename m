From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC] flow : NUMA aware hash table allocation
Date: Tue, 01 Jan 2008 19:23:56 -0800 (PST)
Message-ID: <20080101.192356.30049723.davem@davemloft.net>
References: <477A359F.20902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55863
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752743AbYABDX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 22:23:56 -0500
In-Reply-To: <477A359F.20902@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 01 Jan 2008 13:44:15 +0100

> Using __get_free_pages() has some drawbacks :
> 
> 1) Not NUMA aware
> 
> 2) 2^X page granularity :
> On arches with big PAGE_SIZE, we waste some ram for each cpu.
> 
> (We currently use 1024 pointers, that is at most 8192 bytes, but
> PAGE_SIZE can be 65536 for example : With say 64 possible cpus,
> thats about 56*64 Kbytes that are wasted)
> 
> Using kmalloc_node() can help to solve these two points.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.

It reminds me that flow_hash_shift should at some point be dynamically
sized.  However, currently the flow cache isn't so heavily used and
there are more important fish to fry right now.
