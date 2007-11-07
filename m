From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Wed, 7 Nov 2007 13:13:18 +0100
Message-ID: <20071107121318.GB1817@ff.dom.local>
References: <200711040018.15027.ak@suse.de> <20071103.162337.83099185.davem@davemloft.net> <472DAD90.4050709@cosmosbay.com> <20071107.024114.265595154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, ak@suse.de, netdev@vger.kernel.org,
	acme@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:49113 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750830AbXKGMJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 07:09:28 -0500
Content-Disposition: inline
In-Reply-To: <20071107.024114.265595154.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 07, 2007 at 02:41:14AM -0800, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sun, 04 Nov 2007 12:31:28 +0100
> 
> > [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
> > 
> > As done two years ago on IP route cache table (commit 
> > 22c047ccbc68fa8f3fa57f0e8f906479a062c426) , we can avoid using one lock per 
> > hash bucket for the huge TCP/DCCP hash tables.
> > 
> > On a typical x86_64 platform, this saves about 2MB or 4MB of ram, for litle 
> > performance differences. (we hit a different cache line for the rwlock, but 
> > then the bucket cache line have a better sharing factor among cpus, since we 
> > dirty it less often). For netstat or ss commands that want a full scan of hash 
> > table, we perform fewer memory accesses.
> > 
> > Using a 'small' table of hashed rwlocks should be more than enough to provide 
> > correct SMP concurrency between different buckets, without using too much 
> > memory. Sizing of this table depends on num_possible_cpus() and various CONFIG 
> > settings.
> > 
> > This patch provides some locking abstraction that may ease a future work using 
> >   a different model for TCP/DCCP table.
> > 
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> > Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> I'm going to push this current version to Linus, the space saving
> really justify it and if we want to refine things further we do it
> with followon work rather than blocking this patch.
> 
> Thanks Eric!

I hope my remarks didn't block anything?! I've written it's OK.
So, I'm not sure it's useful or expected, but anyway:

Acked-by: Jarek Poplawski <jarkao2@o2.pl>

Thanks,
Jarek P.
