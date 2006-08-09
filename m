From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] limit rt cache size
Date: Wed, 09 Aug 2006 02:22:17 -0700 (PDT)
Message-ID: <20060809.022217.59657932.davem@davemloft.net>
References: <200608090224.04158.ak@suse.de>
	<44D9984D.9040304@sw.ru>
	<200608091053.18861.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dev@sw.ru, ak@suse.de, akepner@sgi.com, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37017
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030605AbWHIJWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 05:22:13 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200608091053.18861.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 9 Aug 2006 10:53:18 +0200

> If MAX_ORDER = 11, we have a max hash table of 8 MB : 2097152 slots
> But even 2097152 dst need 139810 pages (560 MB of low mem), so 16 times 
> needs... too much ram.
> 
> Probably a test like this is necessary :
> 
> if (ip_rt_max_size > (nr_kernel_pages/8))
>     ip_rt_max_size = (nr_kernel_pages/8);

Perhaps the 8MB limit in my patches is not so arbitrary :-)

But it should be based upon nr_kernel_pages for sure, and
we'd need to kill the __meminidata tag on that thing if
we started to use it like this.
