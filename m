From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash
 table
Date: Wed, 07 Nov 2007 02:41:14 -0800 (PST)
Message-ID: <20071107.024114.265595154.davem@davemloft.net>
References: <200711040018.15027.ak@suse.de>
	<20071103.162337.83099185.davem@davemloft.net>
	<472DAD90.4050709@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@vger.kernel.org, acme@redhat.com, jarkao2@o2.pl
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57494
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752108AbXKGKlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 05:41:15 -0500
In-Reply-To: <472DAD90.4050709@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sun, 04 Nov 2007 12:31:28 +0100

> [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
> 
> As done two years ago on IP route cache table (commit 
> 22c047ccbc68fa8f3fa57f0e8f906479a062c426) , we can avoid using one lock per 
> hash bucket for the huge TCP/DCCP hash tables.
> 
> On a typical x86_64 platform, this saves about 2MB or 4MB of ram, for litle 
> performance differences. (we hit a different cache line for the rwlock, but 
> then the bucket cache line have a better sharing factor among cpus, since we 
> dirty it less often). For netstat or ss commands that want a full scan of hash 
> table, we perform fewer memory accesses.
> 
> Using a 'small' table of hashed rwlocks should be more than enough to provide 
> correct SMP concurrency between different buckets, without using too much 
> memory. Sizing of this table depends on num_possible_cpus() and various CONFIG 
> settings.
> 
> This patch provides some locking abstraction that may ease a future work using 
>   a different model for TCP/DCCP table.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

I'm going to push this current version to Linus, the space saving
really justify it and if we want to refine things further we do it
with followon work rather than blocking this patch.

Thanks Eric!
