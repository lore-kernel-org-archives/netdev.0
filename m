From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash
 table
Date: Thu, 01 Nov 2007 04:03:40 -0700 (PDT)
Message-ID: <20071101.040340.60088560.davem@davemloft.net>
References: <4729A774.9030409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ak@suse.de, acme@redhat.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59075
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750953AbXKALDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 07:03:41 -0400
In-Reply-To: <4729A774.9030409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 01 Nov 2007 11:16:20 +0100

> As done two years ago on IP route cache table (commit 
> 22c047ccbc68fa8f3fa57f0e8f906479a062c426) , we can avoid using one lock per 
> hash bucket for the huge TCP/DCCP hash tables.
> 
> On a typical x86_64 platform, this saves about 2MB or 4MB of ram, for litle 
> performance differences. (we hit a different cache line for the rwlock, but 
> then the bucket cache line have a better sharing factor among cpus, since we 
> dirty it less often)
> 
> Using a 'small' table of hashed rwlocks should be more than enough to provide 
> correct SMP concurrency between different buckets, without using too much 
> memory. Sizing of this table depends on NR_CPUS and various CONFIG settings.
> 
> This patch provides some locking abstraction that may ease a future work using 
>   a different model for TCP/DCCP table.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Nice work Eric.

I've tossed this into my local tree and we'll let this cook
for a few days.  If no problems crop up I will submit it
for 2.6.24 because the memory savings is non-trivial.
