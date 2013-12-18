From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Tue, 17 Dec 2013 21:21:45 -0500 (EST)
Message-ID: <20131217.212145.893665929052097867.davem@davemloft.net>
References: <20131218125643.8ff140371e1f8c306327d354@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ffusco@redhat.com,
	dborkman@redhat.com, tgraf@redhat.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131218125643.8ff140371e1f8c306327d354@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 18 Dec 2013 12:56:43 +1100

> After merging the net-next tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
> 
> In file included from include/linux/hashtable.h:12:0,
>                  from include/linux/elevator.h:5,
>                  from include/linux/blkdev.h:222,
>                  from init/do_mounts.h:2,
>                  from init/do_mounts_rd.c:21:
> include/linux/hash.h:18:22: fatal error: asm/hash.h: No such file or directory
>  #include <asm/hash.h>
>                       ^
> 
> And many more ...
> 
> Caused by commit 71ae8aac3e19 ("lib: introduce arch optimized hash
> library").  Presumably this would break any architecture other than
> x86 :-(

The author believed that putting a header file in asm-generic/
makes it get used automatically by architectures which lack
that header file.

At the very least we have to add a generic-y entry for it to
arch/${ARCH}/include/asm/Kbuild

I'll try to fix this up, thanks for the report.
